// Edge Function: create-user
//
// Crea un usuario nuevo (auth.users + public.usuarios) desde la pantalla de
// Configuracion. Solo puede invocarla un usuario cuyo rol sea 'administrador'.
//
// El cliente Flutter nunca tiene la service role key: por eso esta operacion
// no puede hacerse directamente desde la app y necesita pasar por una Edge
// Function, que si tiene acceso a SUPABASE_SERVICE_ROLE_KEY como secreto.
//
// Invocar con: supabase.functions.invoke('create-user', body: {...})

import { createClient } from "npm:@supabase/supabase-js@2";

// La app corre en otro dominio que Supabase (Netlify, localhost), asi que el
// navegador envia primero una peticion OPTIONS (preflight). Sin estas cabeceras
// la llamada se bloquea del lado del navegador con "Failed to fetch".
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

interface CreateUserPayload {
  email: string;
  password: string;
  nombre_completo: string;
  rol: "administrador" | "tecnico" | "jefe_taller";
  telefono?: string;
}

Deno.serve(async (req: Request) => {
  // Preflight del navegador: responder antes de cualquier validacion.
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Metodo no permitido" }, 405);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return json({ error: "No autenticado" }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

  // Cliente "como el que llama" (respeta RLS) solo para validar identidad y rol.
  const callerClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: callerData, error: callerError } = await callerClient.auth
    .getUser();
  if (callerError || !callerData?.user) {
    return json({ error: "Token invalido" }, 401);
  }

  const { data: callerUsuario, error: callerUsuarioError } = await callerClient
    .from("usuarios")
    .select("rol_id, roles(nombre)")
    .eq("id", callerData.user.id)
    .single();

  // Segun como resuelva el join, `roles` puede venir como objeto o como array.
  const rolesRel = (callerUsuario as
    | { roles?: { nombre?: string } | { nombre?: string }[] }
    | null)?.roles;
  const callerRol = Array.isArray(rolesRel) ? rolesRel[0]?.nombre : rolesRel?.nombre;

  if (callerUsuarioError || callerRol !== "administrador") {
    return json({ error: "Solo un administrador puede crear usuarios" }, 403);
  }

  const payload = (await req.json()) as CreateUserPayload;
  if (
    !payload.email || !payload.password || !payload.nombre_completo ||
    !payload.rol
  ) {
    return json({ error: "Faltan campos obligatorios" }, 400);
  }

  // Cliente admin (service role) para crear el usuario en auth.users.
  const adminClient = createClient(supabaseUrl, serviceRoleKey);

  const { data: rolRow, error: rolError } = await adminClient
    .from("roles")
    .select("id")
    .eq("nombre", payload.rol)
    .single();

  if (rolError || !rolRow) {
    return json({ error: `Rol invalido: ${payload.rol}` }, 400);
  }

  const { data: created, error: createError } = await adminClient.auth.admin
    .createUser({
      email: payload.email,
      password: payload.password,
      email_confirm: true,
    });

  if (createError || !created?.user) {
    return json(
      { error: createError?.message ?? "No se pudo crear el usuario" },
      400,
    );
  }

  const { error: insertError } = await adminClient.from("usuarios").insert({
    id: created.user.id,
    nombre_completo: payload.nombre_completo,
    email: payload.email,
    rol_id: rolRow.id,
    telefono: payload.telefono ?? null,
    usuario_creacion: callerData.user.id,
  });

  if (insertError) {
    // Revertir: si no se pudo crear la fila de perfil, borrar el auth user.
    await adminClient.auth.admin.deleteUser(created.user.id);
    return json({ error: insertError.message }, 400);
  }

  return json({ id: created.user.id }, 200);
});
