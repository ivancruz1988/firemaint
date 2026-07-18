create table public.checklists (
  id                 uuid primary key default gen_random_uuid(),
  nombre             text not null,
  descripcion        text,
  tipo_vehiculo      text check (tipo_vehiculo in ('autobomba', 'cisterna', 'rescate', 'pickup', 'otro', 'general')),
  activo             boolean not null default true,
  fecha_creacion     timestamptz not null default now(),
  fecha_modificacion timestamptz not null default now(),
  usuario_creacion   uuid references auth.users(id)
);

-- checklist_items cumple doble rol: item de plantilla (orden_trabajo_id IS NULL)
-- o instancia ejecutada para una OT puntual (orden_trabajo_id seteado, resultado registrado).
-- La FK a ordenes_trabajo se agrega en 0006, una vez que esa tabla existe.
create table public.checklist_items (
  id                 uuid primary key default gen_random_uuid(),
  checklist_id       uuid not null references public.checklists(id) on delete cascade,
  orden_trabajo_id   uuid,
  descripcion        text not null,
  orden              int not null default 0,
  resultado          text check (resultado in ('cumple', 'no_cumple', 'no_aplica')),
  observacion        text,
  fecha_creacion     timestamptz not null default now(),
  fecha_modificacion timestamptz not null default now(),
  usuario_creacion   uuid references auth.users(id)
);

create trigger trg_checklists_mod before update on public.checklists
  for each row execute function public.set_fecha_modificacion();

create trigger trg_checklist_items_mod before update on public.checklist_items
  for each row execute function public.set_fecha_modificacion();

create index idx_checklist_items_checklist on public.checklist_items(checklist_id);
create index idx_checklist_items_ot on public.checklist_items(orden_trabajo_id);
