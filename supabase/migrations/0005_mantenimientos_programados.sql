create table public.mantenimientos_programados (
  id                      uuid primary key default gen_random_uuid(),
  vehiculo_id             uuid not null references public.vehiculos(id) on delete cascade,
  checklist_id            uuid references public.checklists(id),
  nombre                  text not null,
  descripcion             text,
  frecuencia              text not null check (frecuencia in ('diario', 'semanal', 'mensual', 'anual')),
  proxima_fecha           date not null,
  ultima_fecha_ejecucion  date,
  activo                  boolean not null default true,
  fecha_creacion          timestamptz not null default now(),
  fecha_modificacion      timestamptz not null default now(),
  usuario_creacion        uuid references auth.users(id)
);

create trigger trg_mant_prog_mod before update on public.mantenimientos_programados
  for each row execute function public.set_fecha_modificacion();

create index idx_mant_prog_vehiculo on public.mantenimientos_programados(vehiculo_id);
create index idx_mant_prog_proxima on public.mantenimientos_programados(proxima_fecha) where activo;
