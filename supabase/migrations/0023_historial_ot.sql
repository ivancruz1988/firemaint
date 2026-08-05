-- Historial de cambios propio de cada orden de trabajo: creacion, cambios de
-- estado (con foco en la finalizacion) y novedades que se le vinculan.
-- Se guarda aparte de historial_vehiculo (que es por vehiculo) para poder
-- mostrar la linea de tiempo completa de una OT sin filtrar eventos ajenos.

create table public.historial_ot (
  id                 uuid primary key default gen_random_uuid(),
  orden_trabajo_id   uuid not null references public.ordenes_trabajo(id) on delete cascade,
  evento             text not null check (evento in ('creacion', 'cambio_estado', 'finalizada', 'novedad_vinculada')),
  descripcion        text not null,
  estado_anterior    text,
  estado_nuevo       text,
  novedad_id         uuid references public.novedades(id),
  fecha_evento       timestamptz not null default now(),
  usuario_creacion   uuid references auth.users(id)
);

create index idx_historial_ot_orden on public.historial_ot(orden_trabajo_id, fecha_evento);

alter table public.historial_ot enable row level security;

create policy historial_ot_select on public.historial_ot for select to authenticated
  using (
    public.current_user_role() in ('administrador', 'jefe_taller')
    or orden_trabajo_id in (select id from public.ordenes_trabajo where tecnico_asignado_id = auth.uid())
  );
create policy historial_ot_insert on public.historial_ot for insert to authenticated with check (true);

-- La fecha_fin de la OT nunca se completaba: nada la escribia ni en la app ni
-- en la base. Se completa sola al finalizar, que es cuando tiene sentido.
create or replace function public.completar_fecha_fin_ot()
returns trigger
language plpgsql
as $$
begin
  if new.estado = 'finalizada' and old.estado is distinct from new.estado and new.fecha_fin is null then
    new.fecha_fin := now();
  end if;
  return new;
end;
$$;

drop trigger if exists trg_ot_completar_fecha_fin on public.ordenes_trabajo;
create trigger trg_ot_completar_fecha_fin before update on public.ordenes_trabajo
  for each row execute function public.completar_fecha_fin_ot();

create or replace function public.log_historial_ot_creacion()
returns trigger
language plpgsql
as $$
begin
  insert into public.historial_ot(orden_trabajo_id, evento, descripcion, estado_nuevo, usuario_creacion)
  values (new.id, 'creacion', 'OT creada', new.estado, auth.uid());
  return new;
end;
$$;

drop trigger if exists trg_historial_ot_creacion on public.ordenes_trabajo;
create trigger trg_historial_ot_creacion after insert on public.ordenes_trabajo
  for each row execute function public.log_historial_ot_creacion();

create or replace function public.log_historial_ot_cambio_estado()
returns trigger
language plpgsql
as $$
begin
  if old.estado is distinct from new.estado then
    insert into public.historial_ot(orden_trabajo_id, evento, descripcion, estado_anterior, estado_nuevo, usuario_creacion)
    values (
      new.id,
      case when new.estado = 'finalizada' then 'finalizada' else 'cambio_estado' end,
      case when new.estado = 'finalizada' then 'OT finalizada' else 'Estado cambiado a ' || new.estado end,
      old.estado,
      new.estado,
      auth.uid()
    );
  end if;
  return new;
end;
$$;

drop trigger if exists trg_historial_ot_cambio_estado on public.ordenes_trabajo;
create trigger trg_historial_ot_cambio_estado after update on public.ordenes_trabajo
  for each row execute function public.log_historial_ot_cambio_estado();

-- Una novedad queda vinculada a una OT al crearla (automatizacion de 0020) o
-- al asignarsela despues a mano; cualquiera de los dos casos deja rastro.
create or replace function public.log_historial_ot_novedad()
returns trigger
language plpgsql
as $$
begin
  if new.orden_trabajo_id is not null
     and (tg_op = 'INSERT' or old.orden_trabajo_id is distinct from new.orden_trabajo_id) then
    insert into public.historial_ot(orden_trabajo_id, evento, descripcion, novedad_id, usuario_creacion)
    values (
      new.orden_trabajo_id,
      'novedad_vinculada',
      'Novedad registrada: ' || new.tipo || ' - ' || new.titulo,
      new.id,
      coalesce(new.usuario_creacion, new.reportado_por, auth.uid())
    );
  end if;
  return new;
end;
$$;

drop trigger if exists trg_historial_ot_novedad on public.novedades;
create trigger trg_historial_ot_novedad after insert or update of orden_trabajo_id on public.novedades
  for each row execute function public.log_historial_ot_novedad();
