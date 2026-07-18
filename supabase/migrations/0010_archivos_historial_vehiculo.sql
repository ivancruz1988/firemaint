create table public.archivos (
  id                  uuid primary key default gen_random_uuid(),
  vehiculo_id         uuid references public.vehiculos(id) on delete cascade,
  orden_trabajo_id    uuid references public.ordenes_trabajo(id) on delete cascade,
  novedad_id          uuid references public.novedades(id) on delete cascade,
  checklist_item_id   uuid references public.checklist_items(id) on delete cascade,
  tipo_archivo        text not null check (tipo_archivo in ('foto', 'manual', 'documento', 'foto_antes', 'foto_despues')),
  storage_path        text not null,
  nombre_original     text,
  mime_type           text,
  tamano_bytes        bigint,
  fecha_creacion      timestamptz not null default now(),
  fecha_modificacion  timestamptz not null default now(),
  usuario_creacion    uuid references auth.users(id),
  constraint chk_archivos_un_padre check (
    (vehiculo_id is not null)::int + (orden_trabajo_id is not null)::int +
    (novedad_id is not null)::int + (checklist_item_id is not null)::int = 1
  )
);

create trigger trg_archivos_mod before update on public.archivos
  for each row execute function public.set_fecha_modificacion();

create index idx_archivos_vehiculo on public.archivos(vehiculo_id);
create index idx_archivos_ot on public.archivos(orden_trabajo_id);
create index idx_archivos_novedad on public.archivos(novedad_id);

create table public.historial_vehiculo (
  id                            uuid primary key default gen_random_uuid(),
  vehiculo_id                   uuid not null references public.vehiculos(id) on delete cascade,
  tipo_evento                   text not null check (tipo_evento in ('orden_trabajo', 'novedad', 'mantenimiento', 'cambio_estado')),
  orden_trabajo_id               uuid references public.ordenes_trabajo(id),
  novedad_id                    uuid references public.novedades(id),
  mantenimiento_programado_id   uuid references public.mantenimientos_programados(id),
  descripcion                   text not null,
  fecha_evento                  timestamptz not null default now(),
  fecha_creacion                timestamptz not null default now(),
  fecha_modificacion            timestamptz not null default now(),
  usuario_creacion               uuid references auth.users(id)
);

create trigger trg_historial_mod before update on public.historial_vehiculo
  for each row execute function public.set_fecha_modificacion();

create index idx_historial_vehiculo on public.historial_vehiculo(vehiculo_id, fecha_evento desc);
