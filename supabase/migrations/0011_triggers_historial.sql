create or replace function public.log_historial_ot() returns trigger language plpgsql as $$
begin
  if (tg_op = 'INSERT') or (new.estado is distinct from old.estado) then
    insert into public.historial_vehiculo(vehiculo_id, tipo_evento, orden_trabajo_id, descripcion, usuario_creacion)
    values (new.vehiculo_id, 'orden_trabajo', new.id,
            'OT #' || new.numero_ot || ' - ' || new.titulo || ' (' || new.estado || ')',
            auth.uid());
  end if;
  return new;
end;
$$;

create trigger trg_ot_historial after insert or update on public.ordenes_trabajo
  for each row execute function public.log_historial_ot();

create or replace function public.log_historial_novedad() returns trigger language plpgsql as $$
begin
  insert into public.historial_vehiculo(vehiculo_id, tipo_evento, novedad_id, descripcion, usuario_creacion)
  values (new.vehiculo_id, 'novedad', new.id, new.tipo || ' - ' || new.titulo, auth.uid());
  return new;
end;
$$;

create trigger trg_novedad_historial after insert on public.novedades
  for each row execute function public.log_historial_novedad();

create or replace function public.log_historial_estado_vehiculo() returns trigger language plpgsql as $$
begin
  if new.estado_operativo is distinct from old.estado_operativo then
    insert into public.historial_vehiculo(vehiculo_id, tipo_evento, descripcion, usuario_creacion)
    values (new.id, 'cambio_estado', 'Estado cambiado a ' || new.estado_operativo, auth.uid());
  end if;
  return new;
end;
$$;

create trigger trg_vehiculo_estado_historial after update on public.vehiculos
  for each row execute function public.log_historial_estado_vehiculo();
