// Edge Function: notificar-asignacion
//
// Avisa por mail a un tecnico cuando se le asigna una orden de trabajo.
//
// La invoca el trigger trg_notificar_asignacion_ot (migracion 0015), no la
// app: asi el mail sale igual si la asignacion se hace desde la app, desde el
// panel de Supabase o desde cualquier otro lado.
//
// Requiere el secreto BREVO_API_KEY y las variables BREVO_REMITENTE_EMAIL y
// BREVO_REMITENTE_NOMBRE cargadas en Supabase.

import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

const PRIORIDAD_ETIQUETA: Record<string, string> = {
  baja: "Baja",
  media: "Media",
  alta: "Alta",
  critica: "CRITICA",
};

// El titulo y la descripcion de la OT los escribe un usuario y terminan
// dentro del HTML del mail: sin escapar, podrian inyectar contenido
// arbitrario en un correo que sale a nombre del cuartel.
function escapeHtml(texto: string): string {
  return texto
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ error: "Metodo no permitido" }, 405);
  }

  // A esta funcion solo la llama el trigger de la base, que se autentica con
  // la service role key. La anon key tambien es un JWT valido, asi que el
  // verify-JWT de la plataforma no alcanza: sin este chequeo, cualquiera con
  // la clave publica de la app podria disparar mails a los tecnicos y
  // averiguar sus direcciones.
  const authHeader = req.headers.get("Authorization") ?? "";
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!serviceKey || authHeader !== `Bearer ${serviceKey}`) {
    return json({ error: "No autorizado" }, 401);
  }

  const brevoKey = Deno.env.get("BREVO_API_KEY");
  const remitenteEmail = Deno.env.get("BREVO_REMITENTE_EMAIL");
  const remitenteNombre = Deno.env.get("BREVO_REMITENTE_NOMBRE") ?? "Bomberos Voluntarios";

  if (!brevoKey || !remitenteEmail) {
    return json({ error: "Faltan BREVO_API_KEY o BREVO_REMITENTE_EMAIL" }, 500);
  }

  try {
    const { orden_trabajo_id } = await req.json();
    if (!orden_trabajo_id) {
      return json({ error: "Falta orden_trabajo_id" }, 400);
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Se leen los datos aca y no en el trigger: mantiene el SQL simple y evita
    // que un cambio de formato del mail obligue a tocar la base.
    const { data: ot, error } = await supabase
      .from("ordenes_trabajo")
      .select(
        "numero_ot, titulo, descripcion, prioridad, estado, " +
          "usuarios!ordenes_trabajo_tecnico_asignado_id_fkey(nombre_completo, email, activo), " +
          "vehiculos(dominio, marca, modelo)",
      )
      .eq("id", orden_trabajo_id)
      .single();

    if (error || !ot) {
      return json({ error: `No se encontro la OT: ${error?.message}` }, 404);
    }

    const rel = ot.usuarios as
      | { nombre_completo: string; email: string; activo: boolean }
      | { nombre_completo: string; email: string; activo: boolean }[]
      | null;
    const tecnico = Array.isArray(rel) ? rel[0] : rel;

    if (!tecnico?.email) {
      return json({ mensaje: "La OT no tiene tecnico asignado, no se envia" }, 200);
    }
    // A un usuario dado de baja no tiene sentido avisarle: ya no puede entrar.
    if (!tecnico.activo) {
      return json({ mensaje: "El tecnico esta inactivo, no se envia" }, 200);
    }

    const veh = Array.isArray(ot.vehiculos) ? ot.vehiculos[0] : ot.vehiculos;
    // dominio (la patente) puede no estar cargado; sin el, se muestra marca y
    // modelo solos en lugar de un guion colgado sin nada antes.
    const unidad = escapeHtml(
      veh
        ? `${veh.dominio ? `${veh.dominio} - ` : ""}${veh.marca} ${veh.modelo}`
        : "Sin unidad asignada",
    );
    const prioridad = PRIORIDAD_ETIQUETA[ot.prioridad as string] ?? escapeHtml(`${ot.prioridad}`);
    const titulo = escapeHtml(ot.titulo as string);
    const descripcion = ot.descripcion ? escapeHtml(ot.descripcion as string) : "";
    const nombreTecnico = escapeHtml(tecnico.nombre_completo);

    const html = `
      <div style="font-family:Arial,Helvetica,sans-serif;max-width:520px;margin:0 auto">
        <div style="background:#C62828;color:#fff;padding:16px 20px;border-radius:8px 8px 0 0">
          <h2 style="margin:0;font-size:18px">Nueva orden de trabajo asignada</h2>
        </div>
        <div style="border:1px solid #E3E6EA;border-top:none;padding:20px;border-radius:0 0 8px 8px">
          <p>Hola ${nombreTecnico},</p>
          <p>Se te asigno la orden de trabajo <strong>#${ot.numero_ot}</strong>.</p>
          <table style="width:100%;border-collapse:collapse;margin:16px 0">
            <tr><td style="padding:6px 0;color:#6B7780">Tarea</td><td style="padding:6px 0"><strong>${titulo}</strong></td></tr>
            <tr><td style="padding:6px 0;color:#6B7780">Unidad</td><td style="padding:6px 0">${unidad}</td></tr>
            <tr><td style="padding:6px 0;color:#6B7780">Prioridad</td><td style="padding:6px 0">${prioridad}</td></tr>
          </table>
          ${descripcion ? `<p style="color:#6B7780">${descripcion}</p>` : ""}
          <p style="margin-top:24px">Ingresa al sistema para ver el detalle y registrar el avance.</p>
        </div>
      </div>`;

    const respuesta = await fetch("https://api.brevo.com/v3/smtp/email", {
      method: "POST",
      headers: {
        "api-key": brevoKey,
        "Content-Type": "application/json",
        "accept": "application/json",
      },
      body: JSON.stringify({
        sender: { name: remitenteNombre, email: remitenteEmail },
        to: [{ email: tecnico.email, name: tecnico.nombre_completo }],
        subject: `OT #${ot.numero_ot} asignada: ${ot.titulo}`,
        htmlContent: html,
      }),
    });

    if (!respuesta.ok) {
      const detalle = await respuesta.text();
      return json({ error: `Brevo rechazo el envio: ${detalle}` }, 502);
    }

    // No se devuelve la direccion del tecnico: la respuesta no la necesita y
    // seria un dato personal filtrado a quien llame.
    return json({ mensaje: "Mail enviado" }, 200);
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
