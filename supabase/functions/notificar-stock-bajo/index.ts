// Edge Function: notificar-stock-bajo
//
// Avisa al administrador y al jefe de taller cuando el stock de un repuesto
// cruza hacia abajo el minimo configurado. La invoca el trigger
// trg_notificar_stock_bajo (migracion 0018), nunca la app: asi el aviso sale
// tanto si el stock bajo lo provoco un movimiento como una edicion directa.

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

  // Solo el trigger de la base (autenticado con la service role key) puede
  // disparar este envio.
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
    const { repuesto_id } = await req.json();
    if (!repuesto_id) return json({ error: "Falta repuesto_id" }, 400);

    const supabase = createClient(Deno.env.get("SUPABASE_URL")!, serviceKey);

    const { data: repuesto, error: errRep } = await supabase
      .from("repuestos")
      .select("codigo, descripcion, stock, stock_minimo, unidad_medida, ubicacion")
      .eq("id", repuesto_id)
      .single();

    if (errRep || !repuesto) {
      return json({ error: `No se encontro el repuesto: ${errRep?.message}` }, 404);
    }

    const { data: destinatarios, error: errDest } = await supabase
      .from("usuarios")
      .select("email, nombre_completo, roles(nombre)")
      .eq("activo", true);

    if (errDest) return json({ error: errDest.message }, 500);

    const gestores = (destinatarios ?? []).filter((u) => {
      const rel = u.roles as { nombre?: string } | { nombre?: string }[] | null;
      const rol = Array.isArray(rel) ? rel[0]?.nombre : rel?.nombre;
      return rol === "administrador" || rol === "jefe_taller";
    });

    if (gestores.length === 0) {
      return json({ mensaje: "No hay administradores ni jefes de taller activos" }, 200);
    }

    const descripcion = escapeHtml(repuesto.descripcion as string);
    const codigo = escapeHtml(repuesto.codigo as string);
    const ubicacion = repuesto.ubicacion ? escapeHtml(repuesto.ubicacion as string) : null;

    const html = `
      <div style="font-family:Arial,Helvetica,sans-serif;max-width:520px;margin:0 auto">
        <div style="background:#C62828;color:#fff;padding:16px 20px;border-radius:8px 8px 0 0">
          <h2 style="margin:0;font-size:18px">Stock bajo minimo</h2>
        </div>
        <div style="border:1px solid #E3E6EA;border-top:none;padding:20px;border-radius:0 0 8px 8px">
          <p><strong>${codigo}</strong> - ${descripcion} llego al stock minimo.</p>
          <table style="width:100%;border-collapse:collapse;margin:16px 0">
            <tr><td style="padding:6px 0;color:#6B7780">Stock actual</td>
                <td style="padding:6px 0"><strong>${repuesto.stock} ${escapeHtml(repuesto.unidad_medida as string)}</strong></td></tr>
            <tr><td style="padding:6px 0;color:#6B7780">Minimo configurado</td>
                <td style="padding:6px 0">${repuesto.stock_minimo} ${escapeHtml(repuesto.unidad_medida as string)}</td></tr>
            ${ubicacion ? `<tr><td style="padding:6px 0;color:#6B7780">Ubicacion</td><td style="padding:6px 0">${ubicacion}</td></tr>` : ""}
          </table>
          <p>Ingresa al sistema para registrar la reposicion.</p>
        </div>
      </div>`;

    let enviados = 0;
    for (const g of gestores) {
      const respuesta = await fetch("https://api.brevo.com/v3/smtp/email", {
        method: "POST",
        headers: {
          "api-key": brevoKey,
          "Content-Type": "application/json",
          "accept": "application/json",
        },
        body: JSON.stringify({
          sender: { name: remitenteNombre, email: remitenteEmail },
          to: [{ email: g.email, name: g.nombre_completo }],
          subject: `Stock bajo: ${repuesto.codigo}`,
          htmlContent: html,
        }),
      });
      if (respuesta.ok) enviados++;
    }

    return json({ mensaje: `Mail enviado a ${enviados} de ${gestores.length} destinatarios` }, 200);
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
