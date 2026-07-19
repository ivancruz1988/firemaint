-- Baja logica de usuarios.
--
-- Un usuario dado de baja conserva su historial (las ordenes, checklists y
-- novedades que cargo siguen mostrando su nombre) pero pierde todo acceso.
-- Se prefiere esto al borrado real porque las tablas referencian al autor de
-- cada registro: borrar la fila romperia la trazabilidad del taller.

-- current_user_role() es el unico punto por el que pasan todas las policies
-- RLS del esquema. Devolver null cuando el usuario esta inactivo le quita el
-- acceso a toda la base de una sola vez, sin tener que tocar policy por policy.
create or replace function public.current_user_role()
returns text language sql stable security definer set search_path = public as $$
  select r.nombre from public.usuarios u
  join public.roles r on r.id = u.rol_id
  where u.id = auth.uid() and u.activo;
$$;

-- La policy usuarios_update deja que cada uno edite su propia fila (para
-- corregir su telefono o su nombre). Sin esta proteccion un usuario
-- desactivado podria volver a activarse solo, o cualquiera podria
-- auto-asignarse el rol de administrador.
create or replace function public.proteger_campos_sensibles_usuario()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  -- coalesce es necesario: para un usuario ya inactivo current_user_role()
  -- devuelve null, y `null <> 'administrador'` es null, con lo cual el if
  -- no se ejecutaria y la proteccion quedaria sin efecto.
  if coalesce(public.current_user_role(), '') <> 'administrador' then
    if new.activo is distinct from old.activo then
      raise exception 'Solo un administrador puede activar o desactivar usuarios';
    end if;
    if new.rol_id is distinct from old.rol_id then
      raise exception 'Solo un administrador puede cambiar el rol de un usuario';
    end if;
  end if;

  -- Evita que un administrador se deje afuera del sistema por accidente.
  if old.activo and not new.activo and new.id = auth.uid() then
    raise exception 'No podes desactivar tu propio usuario';
  end if;

  return new;
end;
$$;

drop trigger if exists trg_proteger_campos_usuario on public.usuarios;
create trigger trg_proteger_campos_usuario
  before update on public.usuarios
  for each row execute function public.proteger_campos_sensibles_usuario();
