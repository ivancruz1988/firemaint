-- gen_random_uuid() esta disponible de forma nativa en PostgreSQL 13+ (Supabase), no requiere extension.

create or replace function public.set_fecha_modificacion()
returns trigger language plpgsql as $$
begin
  new.fecha_modificacion := now();
  return new;
end;
$$;
