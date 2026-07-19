-- Chequeo diario de mantenimientos preventivos vencidos.
--
-- Reutiliza config_notificaciones (migracion 0015) para no duplicar la URL
-- de functions ni la service role key en una segunda tabla.

create extension if not exists pg_cron;

create or replace function public.chequear_mantenimientos_vencidos()
returns void language plpgsql security definer set search_path = public as $$
declare
  cfg public.config_notificaciones%rowtype;
  hay_vencidos boolean;
begin
  select * into cfg from public.config_notificaciones where id = 1;
  if not found then
    raise notice 'config_notificaciones vacia: no se chequean vencimientos';
    return;
  end if;

  -- Se filtra aca para no invocar la Edge Function en vano todos los dias
  -- cuando no hay nada vencido; la funcion igual vuelve a filtrar por su
  -- cuenta antes de mandar mail, por si el estado cambio entre medio.
  select exists(
    select 1 from public.mantenimientos_programados
    where activo and proxima_fecha <= current_date
  ) into hay_vencidos;

  if not hay_vencidos then
    return;
  end if;

  perform net.http_post(
    url     := cfg.functions_url || '/notificar-mantenimientos-vencidos',
    headers := jsonb_build_object(
                 'Content-Type', 'application/json',
                 'Authorization', 'Bearer ' || cfg.service_role_key
               ),
    body    := '{}'::jsonb
  );
end;
$$;

-- 11:00 UTC = 8:00 en Argentina (UTC-3 todo el año, sin horario de verano).
select cron.schedule(
  'chequeo-mantenimientos-diario',
  '0 11 * * *',
  $$select public.chequear_mantenimientos_vencidos()$$
);
