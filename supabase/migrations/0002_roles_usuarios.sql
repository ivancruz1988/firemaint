create table public.roles (
  id                 uuid primary key default gen_random_uuid(),
  nombre             text not null unique check (nombre in ('administrador', 'tecnico', 'jefe_taller')),
  descripcion        text,
  fecha_creacion     timestamptz not null default now(),
  fecha_modificacion timestamptz not null default now(),
  usuario_creacion   uuid references auth.users(id)
);

create table public.usuarios (
  id                 uuid primary key references auth.users(id) on delete cascade,
  nombre_completo    text not null,
  email              text not null unique,
  rol_id             uuid not null references public.roles(id),
  telefono           text,
  activo             boolean not null default true,
  fecha_creacion     timestamptz not null default now(),
  fecha_modificacion timestamptz not null default now(),
  usuario_creacion   uuid references auth.users(id)
);

create trigger trg_roles_mod before update on public.roles
  for each row execute function public.set_fecha_modificacion();

create trigger trg_usuarios_mod before update on public.usuarios
  for each row execute function public.set_fecha_modificacion();

create index idx_usuarios_rol on public.usuarios(rol_id);
