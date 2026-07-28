-- Tabla para registrar el historial de cambios de estado de órdenes de trabajo
create table public.historial_cambios_estado (
  id                      uuid primary key default gen_random_uuid(),
  orden_trabajo_id        uuid not null references public.ordenes_trabajo(id) on delete cascade,
  estado_anterior         text,
  estado_nuevo            text not null,
  fecha_cambio            timestamptz not null default now(),
  usuario_id              uuid references auth.users(id),
  observacion             text
);

create index idx_historial_ot on public.historial_cambios_estado(orden_trabajo_id);
create index idx_historial_fecha on public.historial_cambios_estado(fecha_cambio);

-- Función para registrar automáticamente los cambios de estado
create or replace function public.registrar_cambio_estado()
returns trigger as $$
begin
  -- Solo registrar si el estado cambió
  if old.estado is distinct from new.estado then
    insert into public.historial_cambios_estado (
      orden_trabajo_id,
      estado_anterior,
      estado_nuevo,
      usuario_id
    ) values (
      new.id,
      old.estado,
      new.estado,
      auth.uid()
    );
  end if;
  return new;
end;
$$ language plpgsql security definer set search_path = public;

-- Trigger para registrar cambios de estado
create trigger trg_registrar_cambio_estado
after update of estado on public.ordenes_trabajo
for each row execute function public.registrar_cambio_estado();

-- Función para obtener el historial de una orden de trabajo
create or replace function public.obtener_historial_ot(p_orden_id uuid)
returns table (
  id uuid,
  estado_anterior text,
  estado_nuevo text,
  fecha_cambio timestamptz,
  usuario_nombre text,
  observacion text
) as $$
begin
  return query
  select
    h.id,
    h.estado_anterior,
    h.estado_nuevo,
    h.fecha_cambio,
    u.nombre_usuario,
    h.observacion
  from public.historial_cambios_estado h
  left join public.usuarios u on h.usuario_id = u.id
  where h.orden_trabajo_id = p_orden_id
  order by h.fecha_cambio desc;
end;
$$ language plpgsql;

-- Función para calcular tiempos promedio
create or replace function public.calcular_tiempos_promedio(p_orden_id uuid)
returns table (
  dias_generacion_a_realizacion numeric,
  horas_generacion_a_realizacion numeric,
  minutos_generacion_a_realizacion numeric,
  estado_desde text,
  estado_hacia text,
  cantidad_transiciones bigint,
  promedio_dias numeric,
  promedio_horas numeric
) as $$
begin
  -- Tiempo desde generación a finalización/cancelación
  return query
  select
    (extract(epoch from (h.fecha_cambio - ot.fecha_creacion)) / 86400)::numeric as dias,
    (extract(epoch from (h.fecha_cambio - ot.fecha_creacion)) / 3600)::numeric as horas,
    (extract(epoch from (h.fecha_cambio - ot.fecha_creacion)) / 60)::numeric as minutos,
    h.estado_anterior,
    h.estado_nuevo,
    count(*)::bigint,
    (extract(epoch from avg(h.fecha_cambio - ot.fecha_creacion)) / 86400)::numeric,
    (extract(epoch from avg(h.fecha_cambio - ot.fecha_creacion)) / 3600)::numeric
  from public.historial_cambios_estado h
  join public.ordenes_trabajo ot on h.orden_trabajo_id = ot.id
  where ot.id = p_orden_id
  group by h.estado_anterior, h.estado_nuevo;
end;
$$ language plpgsql;

-- Vista para estadísticas globales de tiempos
create or replace view public.vw_estadisticas_tiempos_ot as
select
  h.estado_anterior,
  h.estado_nuevo,
  count(*)::bigint as cantidad_transiciones,
  round((extract(epoch from avg(h.fecha_cambio - ot.fecha_creacion)) / 3600)::numeric, 2) as promedio_horas,
  round((extract(epoch from min(h.fecha_cambio - ot.fecha_creacion)) / 3600)::numeric, 2) as minimo_horas,
  round((extract(epoch from max(h.fecha_cambio - ot.fecha_creacion)) / 3600)::numeric, 2) as maximo_horas
from public.historial_cambios_estado h
join public.ordenes_trabajo ot on h.orden_trabajo_id = ot.id
group by h.estado_anterior, h.estado_nuevo
order by cantidad_transiciones desc;
