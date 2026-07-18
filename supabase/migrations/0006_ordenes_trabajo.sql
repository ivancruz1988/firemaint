create table public.ordenes_trabajo (
  id                            uuid primary key default gen_random_uuid(),
  numero_ot                     bigint generated always as identity,
  vehiculo_id                   uuid not null references public.vehiculos(id),
  titulo                        text not null,
  descripcion                   text,
  prioridad                     text not null default 'media' check (prioridad in ('baja', 'media', 'alta', 'critica')),
  estado                        text not null default 'pendiente'
                                   check (estado in ('pendiente', 'en_proceso', 'esperando_repuestos', 'finalizada', 'cancelada')),
  tecnico_asignado_id           uuid references public.usuarios(id),
  mantenimiento_programado_id   uuid references public.mantenimientos_programados(id),
  novedad_id                    uuid, -- FK agregada en 0007, una vez que novedades existe
  checklist_id                  uuid references public.checklists(id),
  horas_trabajo                 numeric(6, 2),
  costo_estimado                numeric(12, 2),
  costo_real                    numeric(12, 2),
  fecha_inicio                  timestamptz,
  fecha_fin                     timestamptz,
  observaciones                 text,
  fecha_creacion                timestamptz not null default now(),
  fecha_modificacion            timestamptz not null default now(),
  usuario_creacion               uuid references auth.users(id)
);

create trigger trg_ot_mod before update on public.ordenes_trabajo
  for each row execute function public.set_fecha_modificacion();

create index idx_ot_estado on public.ordenes_trabajo(estado);
create index idx_ot_vehiculo on public.ordenes_trabajo(vehiculo_id);
create index idx_ot_tecnico on public.ordenes_trabajo(tecnico_asignado_id);

alter table public.checklist_items
  add constraint fk_checklist_items_ot foreign key (orden_trabajo_id)
  references public.ordenes_trabajo(id) on delete cascade;
