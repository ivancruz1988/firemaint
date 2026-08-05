-- Los tecnicos pasan a ver y actualizar cualquier orden de trabajo, no solo
-- las que tienen asignadas. Antes veian el taller "a traves de un tubo": no
-- se enteraban de lo que hacian los demas ni podian dar una mano en una OT
-- ajena. Crear y borrar OT se mantiene exclusivo de administrador/jefe de
-- taller: eso no cambio, solo la visibilidad y la edicion.
--
-- El aviso personal del Dashboard ("Tenes 3 tareas pendientes") no depende
-- de esta policy: sigue leyendo por tecnico_asignado_id desde el cliente,
-- asi que se mantiene como recordatorio de lo propio aunque ahora se pueda
-- ver y tocar todo.

drop policy if exists ot_select on public.ordenes_trabajo;
create policy ot_select on public.ordenes_trabajo for select to authenticated
  using (public.current_user_role() in ('administrador', 'jefe_taller', 'tecnico'));

drop policy if exists ot_update on public.ordenes_trabajo;
create policy ot_update on public.ordenes_trabajo for update to authenticated
  using (public.current_user_role() in ('administrador', 'jefe_taller', 'tecnico'))
  with check (public.current_user_role() in ('administrador', 'jefe_taller', 'tecnico'));
