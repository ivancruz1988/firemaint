-- Seed de roles base. Ejecutar una sola vez despues de aplicar las migraciones.
insert into public.roles (nombre, descripcion) values
  ('administrador', 'Acceso total: usuarios, vehiculos, planes de mantenimiento, reportes, asignacion de OT'),
  ('tecnico', 'Ejecuta ordenes de trabajo asignadas, checklists, novedades y fotografias'),
  ('jefe_taller', 'Supervisa tareas, aprueba trabajos, consulta indicadores, genera OT')
on conflict (nombre) do nothing;

-- ── Bootstrap del primer administrador ─────────────────────────────
-- La creacion de usuarios desde la app (pantalla Configuracion > Usuarios) requiere
-- que YA exista un administrador, porque pasa por la Edge Function `create-user`
-- que valida el rol del que llama. El primer admin se crea a mano, una unica vez:
--
-- 1. Supabase Dashboard > Authentication > Users > "Add user" (email + password).
-- 2. Copiar el UUID del usuario recien creado.
-- 3. Correr, reemplazando los valores:
--
--   insert into public.usuarios (id, nombre_completo, email, rol_id)
--   values (
--     '<uuid-del-usuario>',
--     'Nombre Completo',
--     'admin@ejemplo.com',
--     (select id from public.roles where nombre = 'administrador')
--   );
--
-- A partir de ahi, ese admin puede crear el resto de los usuarios desde la app.
