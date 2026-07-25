-- Las novedades forman parte del historial operativo y pueden tener una OT
-- asociada. En vez de borrarlas (lo que rompe las referencias del historial),
-- se las anula y se cancela la OT abierta vinculada.

alter table public.novedades
  drop constraint if exists novedades_estado_check;

alter table public.novedades
  add constraint novedades_estado_check
  check (estado in ('abierta', 'en_atencion', 'resuelta', 'anulada'));

create or replace function public.cancelar_ot_por_novedad_anulada()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.estado = 'anulada'
     and old.estado is distinct from new.estado
     and new.orden_trabajo_id is not null then
    update public.ordenes_trabajo
    set estado = 'cancelada',
        observaciones = concat_ws(
          E'\n',
          observaciones,
          'OT cancelada por anulación de la novedad vinculada.'
        )
    where id = new.orden_trabajo_id
      and estado not in ('finalizada', 'cancelada');
  end if;
  return new;
end;
$$;

drop trigger if exists trg_cancelar_ot_por_novedad_anulada on public.novedades;
create trigger trg_cancelar_ot_por_novedad_anulada
after update of estado on public.novedades
for each row execute function public.cancelar_ot_por_novedad_anulada();
