create table public.novedades (
  id                 uuid primary key default gen_random_uuid(),
  vehiculo_id        uuid not null references public.vehiculos(id),
  tipo               text not null check (tipo in ('averia', 'falla', 'accidente', 'reparacion_urgente')),
  titulo             text not null,
  descripcion        text,
  fecha_ocurrencia   timestamptz not null default now(),
  estado             text not null default 'abierta' check (estado in ('abierta', 'en_atencion', 'resuelta')),
  orden_trabajo_id   uuid references public.ordenes_trabajo(id),
  reportado_por      uuid references auth.users(id),
  fecha_creacion     timestamptz not null default now(),
  fecha_modificacion timestamptz not null default now(),
  usuario_creacion   uuid references auth.users(id)
);

create trigger trg_novedades_mod before update on public.novedades
  for each row execute function public.set_fecha_modificacion();

create index idx_novedades_vehiculo on public.novedades(vehiculo_id);
create index idx_novedades_estado on public.novedades(estado);

alter table public.ordenes_trabajo
  add constraint fk_ot_novedad foreign key (novedad_id)
  references public.novedades(id);
