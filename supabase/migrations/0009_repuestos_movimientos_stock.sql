create table public.repuestos (
  id                 uuid primary key default gen_random_uuid(),
  codigo             text not null unique,
  descripcion        text not null,
  stock              numeric(10, 2) not null default 0,
  stock_minimo       numeric(10, 2) not null default 0,
  ubicacion          text,
  unidad_medida      text default 'unidad',
  costo_unitario     numeric(12, 2),
  activo             boolean not null default true,
  fecha_creacion     timestamptz not null default now(),
  fecha_modificacion timestamptz not null default now(),
  usuario_creacion   uuid references auth.users(id)
);

create trigger trg_repuestos_mod before update on public.repuestos
  for each row execute function public.set_fecha_modificacion();

create index idx_repuestos_bajo_stock on public.repuestos(stock) where stock <= stock_minimo;

create table public.movimientos_stock (
  id                 uuid primary key default gen_random_uuid(),
  repuesto_id        uuid not null references public.repuestos(id),
  tipo_movimiento    text not null check (tipo_movimiento in ('ingreso', 'egreso', 'ajuste')),
  cantidad           numeric(10, 2) not null,
  orden_trabajo_id   uuid references public.ordenes_trabajo(id),
  motivo             text,
  fecha_creacion     timestamptz not null default now(),
  fecha_modificacion timestamptz not null default now(),
  usuario_creacion   uuid references auth.users(id)
);

create trigger trg_mov_stock_mod before update on public.movimientos_stock
  for each row execute function public.set_fecha_modificacion();

create index idx_mov_stock_repuesto on public.movimientos_stock(repuesto_id);
