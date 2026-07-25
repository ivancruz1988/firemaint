-- Generacion automatica de ordenes de trabajo.
--
-- Reglas:
-- 1) Una novedad abierta crea una OT de inmediato.
-- 2) Un plan preventivo crea una OT cuando llega su proxima fecha.
-- 3) Cada nueva OT se asigna al tecnico activo con menos OT abiertas.

create or replace function public.tecnico_menos_cargado()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select u.id
  from public.usuarios u
  join public.roles r on r.id = u.rol_id
  left join public.ordenes_trabajo ot
    on ot.tecnico_asignado_id = u.id
   and ot.estado in ('pendiente', 'en_proceso', 'esperando_repuestos')
  where u.activo = true
    and r.nombre = 'tecnico'
  group by u.id, u.nombre_completo
  order by count(ot.id) asc, u.nombre_completo asc
  limit 1;
$$;

create or replace function public.generar_ot_por_novedad()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  tecnico_id uuid;
  orden_id uuid;
  prioridad_ot text;
begin
  -- Una novedad ya resuelta no necesita abrir una orden.
  if new.estado = 'resuelta' or new.orden_trabajo_id is not null then
    return new;
  end if;

  tecnico_id := public.tecnico_menos_cargado();
  prioridad_ot := case new.tipo
    when 'reparacion_urgente' then 'critica'
    when 'accidente' then 'alta'
    when 'averia' then 'alta'
    else 'media'
  end;

  insert into public.ordenes_trabajo (
    vehiculo_id, titulo, descripcion, prioridad, estado,
    tecnico_asignado_id, novedad_id, usuario_creacion
  ) values (
    new.vehiculo_id,
    'Novedad: ' || new.titulo,
    new.descripcion,
    prioridad_ot,
    'pendiente',
    tecnico_id,
    new.id,
    coalesce(new.usuario_creacion, new.reportado_por, auth.uid())
  ) returning id into orden_id;

  update public.novedades
  set orden_trabajo_id = orden_id,
      estado = 'en_atencion'
  where id = new.id;

  return new;
end;
$$;

drop trigger if exists trg_generar_ot_por_novedad on public.novedades;
create trigger trg_generar_ot_por_novedad
after insert on public.novedades
for each row execute function public.generar_ot_por_novedad();

create or replace function public.generar_ots_preventivas()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  plan record;
  tecnico_id uuid;
  cantidad integer := 0;
  siguiente_fecha date;
begin
  -- FOR UPDATE SKIP LOCKED evita duplicados si el cron se ejecuta dos veces
  -- o si dos personas crean planes simultaneamente.
  for plan in
    select *
    from public.mantenimientos_programados
    where activo = true and proxima_fecha <= current_date
    order by proxima_fecha, fecha_creacion
    for update skip locked
  loop
    tecnico_id := public.tecnico_menos_cargado();

    insert into public.ordenes_trabajo (
      vehiculo_id, titulo, descripcion, prioridad, estado,
      tecnico_asignado_id, mantenimiento_programado_id, checklist_id,
      usuario_creacion
    ) values (
      plan.vehiculo_id,
      'Preventivo: ' || plan.nombre,
      plan.descripcion,
      'media',
      'pendiente',
      tecnico_id,
      plan.id,
      plan.checklist_id,
      plan.usuario_creacion
    );

    siguiente_fecha := case plan.frecuencia
      when 'diario' then plan.proxima_fecha + 1
      when 'semanal' then plan.proxima_fecha + 7
      when 'mensual' then (plan.proxima_fecha + interval '1 month')::date
      when 'anual' then (plan.proxima_fecha + interval '1 year')::date
    end;

    update public.mantenimientos_programados
    set ultima_fecha_ejecucion = plan.proxima_fecha,
        proxima_fecha = siguiente_fecha
    where id = plan.id;

    cantidad := cantidad + 1;
  end loop;

  return cantidad;
end;
$$;

-- Si se crea un plan con fecha de hoy o vencida, genera la OT en ese instante.
create or replace function public.generar_ot_si_plan_vencido()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.activo and new.proxima_fecha <= current_date then
    perform public.generar_ots_preventivas();
  end if;
  return new;
end;
$$;

drop trigger if exists trg_generar_ot_si_plan_vencido on public.mantenimientos_programados;
create trigger trg_generar_ot_si_plan_vencido
after insert on public.mantenimientos_programados
for each row execute function public.generar_ot_si_plan_vencido();

-- Ejecuta todos los dias a las 08:05 de Argentina (11:05 UTC).
create extension if not exists pg_cron;
select cron.unschedule(jobid)
from cron.job
where jobname = 'generar-ots-preventivas-diarias';

select cron.schedule(
  'generar-ots-preventivas-diarias',
  '5 11 * * *',
  $$select public.generar_ots_preventivas()$$
);
