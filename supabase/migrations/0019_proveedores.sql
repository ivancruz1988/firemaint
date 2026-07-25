-- Agenda compartida de proveedores del cuartel.
create table if not exists public.proveedores (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  rubro text,
  contacto text,
  telefono text,
  whatsapp text,
  email text,
  direccion text,
  localidad text,
  notas text,
  activo boolean not null default true,
  fecha_creacion timestamptz not null default now(),
  fecha_modificacion timestamptz not null default now(),
  usuario_creacion uuid references public.usuarios(id)
);

create index if not exists proveedores_nombre_idx on public.proveedores (nombre);
create index if not exists proveedores_rubro_idx on public.proveedores (rubro);

drop trigger if exists proveedores_fecha_modificacion on public.proveedores;
create trigger proveedores_fecha_modificacion
before update on public.proveedores
for each row execute function public.set_fecha_modificacion();

alter table public.proveedores enable row level security;

create policy proveedores_select on public.proveedores
for select to authenticated using (true);

create policy proveedores_insert on public.proveedores
for insert to authenticated
with check (public.current_user_role() in ('administrador', 'jefe_taller'));

create policy proveedores_update on public.proveedores
for update to authenticated
using (public.current_user_role() in ('administrador', 'jefe_taller'))
with check (public.current_user_role() in ('administrador', 'jefe_taller'));

create policy proveedores_delete on public.proveedores
for delete to authenticated
using (public.current_user_role() = 'administrador');
