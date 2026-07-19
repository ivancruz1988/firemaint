-- Aviso por mail al tecnico cuando se le asigna una orden de trabajo.
--
-- El disparo se hace desde la base y no desde la app a proposito: asi el mail
-- sale igual si la asignacion se hace desde la aplicacion, desde el panel de
-- Supabase o desde cualquier otro lado.

create extension if not exists pg_net;

-- Guarda la URL del proyecto y la clave de servicio para que el trigger pueda
-- llamar a la Edge Function. Se completan con el script de mas abajo.
create table if not exists public.config_notificaciones (
  id                integer primary key default 1 check (id = 1),
  functions_url     text not null,
  service_role_key  text not null
);

alter table public.config_notificaciones enable row level security;
-- Sin policies: nadie la lee desde la app. El trigger la accede via
-- security definer, que no pasa por RLS. El revoke es una segunda capa por
-- si alguna vez se crea una policy permisiva por error: esta tabla guarda
-- la clave maestra del proyecto y no debe ser legible por ningun rol de API.
revoke all on public.config_notificaciones from anon, authenticated;

create or replace function public.notificar_asignacion_ot()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  cfg public.config_notificaciones%rowtype;
begin
  -- Solo interesa cuando aparece un tecnico asignado o cuando cambia por otro.
  if new.tecnico_asignado_id is null then
    return new;
  end if;
  if tg_op = 'UPDATE' and old.tecnico_asignado_id is not distinct from new.tecnico_asignado_id then
    return new;
  end if;

  select * into cfg from public.config_notificaciones where id = 1;
  if not found then
    -- Sin configurar, la asignacion tiene que funcionar igual: el mail es un
    -- extra, no una condicion para poder trabajar.
    raise notice 'config_notificaciones vacia: no se envia el aviso';
    return new;
  end if;

  -- net.http_post es asincrono: encola el pedido y sigue. Si el mail falla,
  -- la orden de trabajo se guarda lo mismo.
  perform net.http_post(
    url     := cfg.functions_url || '/notificar-asignacion',
    headers := jsonb_build_object(
                 'Content-Type', 'application/json',
                 'Authorization', 'Bearer ' || cfg.service_role_key
               ),
    body    := jsonb_build_object('orden_trabajo_id', new.id)
  );

  return new;
end;
$$;

drop trigger if exists trg_notificar_asignacion_ot on public.ordenes_trabajo;
create trigger trg_notificar_asignacion_ot
  after insert or update of tecnico_asignado_id on public.ordenes_trabajo
  for each row execute function public.notificar_asignacion_ot();
