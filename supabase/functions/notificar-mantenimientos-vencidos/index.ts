// Edge Function: notificar-mantenimientos-vencidos
//
// Chequeo diario de mantenimientos preventivos vencidos. La invoca un cron
// de la base (migracion 0017), nunca la app. Manda UN mail resumen por
// destinatario (admin/jefe_taller), no uno por cada plan vencido: con varias
// unidades venciendo el mismo dia, un mail por item seria spam.

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

  // Igual que notificar-asignacion: solo el cron de la base (autenticado con
  // la service role key) puede disparar este envio.
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
    const supabase = createClient(Deno.env.get("SUPABASE_URL")!, serviceKey);

    const hoy = new Date().toISOString().slice(0, 10);
    const { data: vencidos, error: errVencidos } = await supabase
      .from("mantenimientos_programados")
      .select("nombre, proxima_fecha, vehiculos(dominio, marca, modelo, numero_interno)")
      .eq("activo", true)
      .lte("proxima_fecha", hoy)
      .order("proxima_fecha");

    if (errVencidos) return json({ error: errVencidos.message }, 500);
    if (!vencidos || vencidos.length === 0) {
      return json({ mensaje: "Sin mantenimientos vencidos, no se envia nada" }, 200);
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

    const filas = vencidos
      .map((m) => {
        const veh = Array.isArray(m.vehiculos) ? m.vehiculos[0] : m.vehiculos;
        const dominio = veh?.dominio ? ` (${veh.dominio})` : "";
        const unidad = veh
          ? `${veh.numero_interno} - ${veh.marca} ${veh.modelo}${dominio}`
          : "Unidad no encontrada";
        return `<tr>
          <td style="padding:6px 8px;border-bottom:1px solid #E3E6EA">${escapeHtml(m.nombre)}</td>
          <td style="padding:6px 8px;border-bottom:1px solid #E3E6EA">${escapeHtml(unidad)}</td>
          <td style="padding:6px 8px;border-bottom:1px solid #E3E6EA">${m.proxima_fecha}</td>
        </tr>`;
      })
      .join("");

    const html = `
      <div style="font-family:Arial,Helvetica,sans-serif;max-width:600px;margin:0 auto">
        <div style="background:#C62828;color:#fff;padding:16px 20px;border-radius:8px 8px 0 0">
          <h2 style="margin:0;font-size:18px">Mantenimientos preventivos vencidos</h2>
        </div>
        <div style="border:1px solid #E3E6EA;border-top:none;padding:20px;border-radius:0 0 8px 8px">
          <p>Hay <strong>${vencidos.length}</strong> plan(es) de mantenimiento preventivo
          vencido(s) o que vencen hoy:</p>
          <table style="width:100%;border-collapse:collapse;margin:16px 0;font-size:13px">
            <tr style="background:#F4F5F7">
              <th style="padding:6px 8px;text-align:left">Plan</th>
              <th style="padding:6px 8px;text-align:left">Unidad</th>
              <th style="padding:6px 8px;text-align:left">Vencio</th>
            </tr>
            ${filas}
          </table>
          <p>Ingresa al sistema para crear la orden de trabajo correspondiente.</p>
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
          subject: `${vencidos.length} mantenimiento(s) preventivo(s) vencido(s)`,
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
