-- Corrige una condicion de carrera en el registro de movimientos de stock.
--
-- Antes, el cliente Flutter leia repuestos.stock, calculaba el nuevo valor
-- en Dart y lo escribia en una segunda llamada separada. Dos movimientos
-- casi simultaneos del mismo repuesto (dos tecnicos usando la misma pieza)
-- podian leer el mismo stock viejo y pisarse: el ultimo update ganaba y el
-- efecto del otro se perdia del conteo, aunque el movimiento quedara bien
-- registrado en la tabla de auditoria.
--
-- Se mueve el calculo a un trigger, que lee y escribe dentro de la misma
-- sentencia: Postgres serializa los updates concurrentes sobre la misma
-- fila, asi que el segundo movimiento siempre parte del valor que dejo el
-- primero, en vez de una foto vieja traida desde el cliente.
create or replace function public.aplicar_movimiento_stock()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  update public.repuestos
  set stock = case new.tipo_movimiento
    when 'ingreso' then stock + new.cantidad
    when 'egreso' then stock - new.cantidad
    when 'ajuste' then new.cantidad
    else stock
  end
  where id = new.repuesto_id;

  return new;
end;
$$;

drop trigger if exists trg_aplicar_movimiento_stock on public.movimientos_stock;
create trigger trg_aplicar_movimiento_stock after insert on public.movimientos_stock
  for each row execute function public.aplicar_movimiento_stock();

-- Aviso de stock bajo minimo al administrador y al jefe de taller.
--
-- Vive en un trigger de UPDATE sobre repuestos (no en el de movimientos de
-- arriba) para cubrir en un solo lugar los dos caminos por los que cambia el
-- stock: registrar un movimiento (que dispara este UPDATE a traves del
-- trigger de arriba) y la edicion directa de stock o de stock_minimo desde
-- el formulario del repuesto.
--
-- Se avisa solo en el cruce hacia abajo (estaba por encima del minimo, ahora
-- esta en o por debajo), no en cada actualizacion mientras ya esta bajo:
-- evita un mail por cada unidad que se sigue consumiendo estando bajo.
create or replace function public.notificar_stock_bajo()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  cfg public.config_notificaciones%rowtype;
begin
  if new.activo and old.stock > old.stock_minimo and new.stock <= new.stock_minimo then
    select * into cfg from public.config_notificaciones where id = 1;
    if found then
      perform net.http_post(
        url     := cfg.functions_url || '/notificar-stock-bajo',
        headers := jsonb_build_object(
                     'Content-Type', 'application/json',
                     'Authorization', 'Bearer ' || cfg.service_role_key
                   ),
        body    := jsonb_build_object('repuesto_id', new.id)
      );
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_notificar_stock_bajo on public.repuestos;
create trigger trg_notificar_stock_bajo after update on public.repuestos
  for each row execute function public.notificar_stock_bajo();
