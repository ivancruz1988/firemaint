create table public.vehiculos (
  id                 uuid primary key default gen_random_uuid(),
  numero_interno     text not null unique,
  dominio            text unique,
  marca              text not null,
  modelo             text not null,
  anio               int check (anio between 1950 and 2100),
  tipo               text not null check (tipo in ('autobomba', 'cisterna', 'rescate', 'pickup', 'otro')),
  kilometraje        numeric(10, 2) default 0,
  horas_bomba        numeric(10, 2) default 0,
  fecha_alta         date not null default current_date,
  estado_operativo   text not null default 'operativo'
                       check (estado_operativo in ('operativo', 'fuera_de_servicio', 'en_mantenimiento')),
  observaciones      text,
  fecha_creacion     timestamptz not null default now(),
  fecha_modificacion timestamptz not null default now(),
  usuario_creacion   uuid references auth.users(id)
);

create trigger trg_vehiculos_mod before update on public.vehiculos
  for each row execute function public.set_fecha_modificacion();

create index idx_vehiculos_estado on public.vehiculos(estado_operativo);
create index idx_vehiculos_tipo on public.vehiculos(tipo);
