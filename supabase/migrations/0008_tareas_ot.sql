create table public.tareas_ot (
  id                 uuid primary key default gen_random_uuid(),
  orden_trabajo_id   uuid not null references public.ordenes_trabajo(id) on delete cascade,
  descripcion        text not null,
  completada         boolean not null default false,
  orden              int not null default 0,
  fecha_creacion     timestamptz not null default now(),
  fecha_modificacion timestamptz not null default now(),
  usuario_creacion   uuid references auth.users(id)
);

create trigger trg_tareas_ot_mod before update on public.tareas_ot
  for each row execute function public.set_fecha_modificacion();

create index idx_tareas_ot_orden_trabajo on public.tareas_ot(orden_trabajo_id);
