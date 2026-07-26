// Edge Function: ask-database
//
// Consulta en lenguaje natural sobre los datos del cuartel (RAG).
//
// Flujo:
// 1. Recibe la pregunta del usuario (autenticado).
// 2. Arma contexto desde la base: un resumen del estado general (siempre) mas
//    las filas que matcheen palabras clave de la pregunta.
// 3. Le pasa pregunta + contexto a Claude.
// 4. Devuelve la respuesta.
//
// El cliente se crea con el JWT del usuario, asi que RLS sigue aplicando: la
// funcion no puede mostrar nada que ese usuario no pudiera ver en la app.
//
// Requiere el secreto ANTHROPIC_API_KEY cargado en Supabase.

import { createClient, SupabaseClient } from "npm:@supabase/supabase-js@2";

const ORIGEN_PRODUCCION = Deno.env.get("ALLOWED_ORIGIN") ||
  "https://firemaint.netlify.app";

/// `flutter run` sirve la app en un puerto al azar de localhost, asi que en
/// desarrollo se acepta cualquier puerto local en vez de una lista fija. Todo
/// otro origen cae al de produccion, o sea que el navegador le bloquea la
/// respuesta.
function origenPermitido(origen: string): string {
  if (origen === ORIGEN_PRODUCCION) return origen;
  if (/^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origen)) return origen;
  return ORIGEN_PRODUCCION;
}

function getCorsHeaders(requestOrigin: string): Record<string, string> {
  return {
    "Access-Control-Allow-Origin": origenPermitido(requestOrigin),
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };
}

function json(body: unknown, status: number, origin?: string): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...getCorsHeaders(origin || ""),
      "Content-Type": "application/json",
    },
  });
}

// Palabras que no aportan nada como criterio de busqueda: sin filtrarlas,
// "de"/"que" matchean casi todas las filas y el contexto se llena de ruido.
const VACIAS = new Set([
  "que", "cual", "cuales", "cuanto", "cuantos", "cuantas", "como", "cuando",
  "donde", "quien", "por", "para", "con", "sin", "del", "las", "los", "una",
  "uno", "unos", "unas", "hay", "esta", "estan", "tiene", "tienen", "son",
  "ser", "the", "and", "and", "dame", "mostrame", "decime", "listame",
]);

/// Envuelve el patron ilike en comillas dobles: sin esto, una coma o un
/// parentesis en la pregunta rompe (o altera) la lista de condiciones del
/// `.or(...)` de PostgREST.
function patronIlike(texto: string): string {
  const escapado = texto.replaceAll("\\", "\\\\").replaceAll('"', '\\"');
  return `"%${escapado}%"`;
}

function palabrasClave(pregunta: string): string[] {
  return pregunta
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\s]/gu, " ")
    .split(/\s+/)
    .filter((p) => p.length >= 4 && !VACIAS.has(p))
    .slice(0, 5);
}

/// Estado general de la flota. Va siempre, porque la mayoria de las preguntas
/// ("cuantas OT hay abiertas", "que unidades estan fuera de servicio") se
/// responden con esto y no con una busqueda por texto.
async function resumen(supabase: SupabaseClient): Promise<string> {
  const [vehiculos, ordenes, novedades, repuestos] = await Promise.all([
    supabase.from("vehiculos").select(
      "numero_interno, dominio, marca, modelo, estado_operativo, kilometraje",
    ),
    supabase.from("ordenes_trabajo").select(
      "numero_ot, titulo, estado, prioridad, fecha_creacion",
    ).order("fecha_creacion", { ascending: false }).limit(25),
    supabase.from("novedades").select("titulo, tipo, estado, fecha_creacion")
      .order("fecha_creacion", { ascending: false }).limit(10),
    supabase.from("repuestos").select("codigo, descripcion, stock, stock_minimo"),
  ]);

  let texto = "";

  if (vehiculos.data?.length) {
    texto += `FLOTA (${vehiculos.data.length} unidades):\n`;
    for (const v of vehiculos.data) {
      texto += `- ${v.numero_interno} ${v.marca} ${v.modelo}` +
        `${v.dominio ? ` (${v.dominio})` : ""} — ${v.estado_operativo}` +
        `, ${v.kilometraje} km\n`;
    }
    texto += "\n";
  }

  if (ordenes.data?.length) {
    texto += `ORDENES DE TRABAJO (ultimas ${ordenes.data.length}):\n`;
    for (const o of ordenes.data) {
      texto += `- #${o.numero_ot} [${o.estado}/${o.prioridad}] ${o.titulo}` +
        ` (${String(o.fecha_creacion).slice(0, 10)})\n`;
    }
    texto += "\n";
  }

  if (novedades.data?.length) {
    texto += `NOVEDADES (ultimas ${novedades.data.length}):\n`;
    for (const n of novedades.data) {
      texto += `- [${n.tipo}/${n.estado}] ${n.titulo}` +
        ` (${String(n.fecha_creacion).slice(0, 10)})\n`;
    }
    texto += "\n";
  }

  if (repuestos.data?.length) {
    const bajos = repuestos.data.filter((r) => r.stock <= r.stock_minimo);
    texto += `REPUESTOS: ${repuestos.data.length} en total, ` +
      `${bajos.length} en stock bajo.\n`;
    for (const r of bajos) {
      texto += `- BAJO: ${r.codigo} ${r.descripcion}` +
        ` (${r.stock}/${r.stock_minimo})\n`;
    }
    texto += "\n";
  }

  return texto;
}

/// Filas que matchean palabras concretas de la pregunta ("bomba", "escalera",
/// una patente). Complementa al resumen, que no incluye descripciones largas.
async function coincidencias(
  supabase: SupabaseClient,
  pregunta: string,
): Promise<string> {
  const claves = palabrasClave(pregunta);
  if (claves.length === 0) return "";

  const filtroOt = claves
    .map((k) => {
      const p = patronIlike(k);
      return `titulo.ilike.${p},descripcion.ilike.${p}`;
    })
    .join(",");

  const { data } = await supabase
    .from("ordenes_trabajo")
    .select("numero_ot, titulo, descripcion, estado, prioridad")
    .or(filtroOt)
    .limit(8);

  if (!data?.length) return "";

  let texto = `DETALLE RELACIONADO CON LA CONSULTA (${claves.join(", ")}):\n`;
  for (const o of data) {
    texto += `- #${o.numero_ot} [${o.estado}] ${o.titulo}\n`;
    if (o.descripcion) texto += `  ${o.descripcion}\n`;
  }
  return `${texto}\n`;
}

async function preguntarAClaude(
  pregunta: string,
  contexto: string,
): Promise<string> {
  const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
  if (!apiKey) throw new Error("Falta configurar ANTHROPIC_API_KEY");

  const prompt =
    `Estos son los datos actuales del sistema de mantenimiento del cuartel:\n\n` +
    `${contexto}\n\nPregunta: ${pregunta}\n\n` +
    `Respondé usando UNICAMENTE los datos de arriba. Si el dato no esta, deci ` +
    `claramente que no figura en el sistema; no lo inventes ni lo estimes.`;

  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: "claude-haiku-4-5-20251001",
      max_tokens: 1024,
      system:
        "Sos un asistente del sistema de mantenimiento de un cuartel de " +
        "bomberos voluntarios. Respondes en castellano rioplatense, breve y " +
        "concreto.",
      messages: [{ role: "user", content: prompt }],
    }),
  });

  if (!res.ok) {
    const detalle = await res.text();
    console.error("Claude rechazo la consulta:", detalle);
    // Se devuelve el motivo de Anthropic (nunca la API key, que va en un
    // header propio, no en el cuerpo) porque si no el usuario ve un numero
    // de status y nada mas.
    let motivo = detalle;
    try {
      motivo = JSON.parse(detalle)?.error?.message ?? detalle;
    } catch (_) {
      // Si no es JSON, se muestra el texto tal cual.
    }
    throw new Error(`Claude (${res.status}): ${motivo}`);
  }

  const data = await res.json();
  const texto = data?.content?.[0]?.text;
  if (!texto) throw new Error("El servicio de consultas no devolvio respuesta");
  return texto as string;
}

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("Origin") || "";

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: getCorsHeaders(origin) });
  }
  if (req.method !== "POST") {
    return json({ error: "Metodo no permitido" }, 405, origin);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "No autenticado" }, 401, origin);

  try {
    const { query } = await req.json();
    if (typeof query !== "string" || query.trim().length === 0) {
      return json({ error: "La consulta esta vacia" }, 400, origin);
    }
    const pregunta = query.trim().slice(0, 500);

    // Con el JWT del usuario: RLS decide que filas puede ver.
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const [general, detalle] = await Promise.all([
      resumen(supabase),
      coincidencias(supabase, pregunta),
    ]);
    const contexto = `${general}${detalle}`.trim();

    if (contexto.length === 0) {
      return json({
        answer: "No hay datos cargados en el sistema para responder todavia.",
      }, 200, origin);
    }

    const answer = await preguntarAClaude(pregunta, contexto);
    return json({ answer }, 200, origin);
  } catch (e) {
    console.error("ask-database:", e);
    return json({ error: (e as Error).message }, 500, origin);
  }
});
