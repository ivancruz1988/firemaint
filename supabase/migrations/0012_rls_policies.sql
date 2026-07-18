-- Resuelve el rol del usuario autenticado una sola vez por policy check.
-- SECURITY DEFINER + STABLE evita el problema de recursion de RLS al
-- hacer join usuarios <-> roles dentro de las policies de otras tablas.
create or replace function public.current_user_role()
returns text language sql stable security definer set search_path = public as $$
  select r.nombre from public.usuarios u
  join public.roles r on r.id = u.rol_id
  where u.id = auth.uid();
$$;

alter table public.roles enable row level security;
alter table public.usuarios enable row level security;
alter table public.vehiculos enable row level security;
alter table public.checklists enable row level security;
alter table public.checklist_items enable row level security;
alter table public.mantenimientos_programados enable row level security;
alter table public.ordenes_trabajo enable row level security;
alter table public.novedades enable row level security;
alter table public.tareas_ot enable row level security;
alter table public.repuestos enable row level security;
alter table public.movimientos_stock enable row level security;
alter table public.archivos enable row level security;
alter table public.historial_vehiculo enable row level security;

-- ── roles ───────────────────────────────────────────────────────────
-- todos los autenticados pueden leer (necesario para dropdowns), solo admin escribe
create policy roles_select on public.roles for select to authenticated using (true);
create policy roles_admin_write on public.roles for all to authenticated
  using (public.current_user_role() = 'administrador')
  with check (public.current_user_role() = 'administrador');

-- ── usuarios ────────────────────────────────────────────────────────
create policy usuarios_select on public.usuarios for select to authenticated
  using (id = auth.uid() or public.current_user_role() in ('administrador', 'jefe_taller'));
create policy usuarios_admin_insert on public.usuarios for insert to authenticated
  with check (public.current_user_role() = 'administrador');
create policy usuarios_update on public.usuarios for update to authenticated
  using (public.current_user_role() = 'administrador' or id = auth.uid())
  with check (public.current_user_role() = 'administrador' or id = auth.uid());
create policy usuarios_admin_delete on public.usuarios for delete to authenticated
  using (public.current_user_role() = 'administrador');

-- ── vehiculos ───────────────────────────────────────────────────────
-- los 3 roles leen; crear/editar es admin + jefe_taller; borrar solo admin
create policy vehiculos_select on public.vehiculos for select to authenticated using (true);
create policy vehiculos_insert on public.vehiculos for insert to authenticated
  with check (public.current_user_role() in ('administrador', 'jefe_taller'));
create policy vehiculos_update on public.vehiculos for update to authenticated
  using (public.current_user_role() in ('administrador', 'jefe_taller'))
  with check (public.current_user_role() in ('administrador', 'jefe_taller'));
create policy vehiculos_delete on public.vehiculos for delete to authenticated
  using (public.current_user_role() = 'administrador');

-- ── checklists / checklist_items (plantillas) ──────────────────────
create policy checklists_select on public.checklists for select to authenticated using (true);
create policy checklists_write on public.checklists for insert to authenticated
  with check (public.current_user_role() in ('administrador', 'jefe_taller'));
create policy checklists_update on public.checklists for update to authenticated
  using (public.current_user_role() in ('administrador', 'jefe_taller'))
  with check (public.current_user_role() in ('administrador', 'jefe_taller'));
create policy checklists_delete on public.checklists for delete to authenticated
  using (public.current_user_role() in ('administrador', 'jefe_taller'));

-- checklist_items: tecnico puede insertar/actualizar solo instancias (orden_trabajo_id set)
-- de una OT que tiene asignada; admin/jefe_taller manejan todo (plantillas e instancias).
create policy checklist_items_select on public.checklist_items for select to authenticated using (true);
create policy checklist_items_insert on public.checklist_items for insert to authenticated
  with check (
    public.current_user_role() in ('administrador', 'jefe_taller')
    or (
      public.current_user_role() = 'tecnico'
      and orden_trabajo_id in (
        select id from public.ordenes_trabajo where tecnico_asignado_id = auth.uid()
      )
    )
  );
create policy checklist_items_update on public.checklist_items for update to authenticated
  using (
    public.current_user_role() in ('administrador', 'jefe_taller')
    or (
      public.current_user_role() = 'tecnico'
      and orden_trabajo_id in (
        select id from public.ordenes_trabajo where tecnico_asignado_id = auth.uid()
      )
    )
  )
  with check (
    public.current_user_role() in ('administrador', 'jefe_taller')
    or (
      public.current_user_role() = 'tecnico'
      and orden_trabajo_id in (
        select id from public.ordenes_trabajo where tecnico_asignado_id = auth.uid()
      )
    )
  );
create policy checklist_items_delete on public.checklist_items for delete to authenticated
  using (public.current_user_role() in ('administrador', 'jefe_taller'));

-- ── mantenimientos_programados ─────────────────────────────────────
create policy mant_prog_select on public.mantenimientos_programados for select to authenticated using (true);
create policy mant_prog_write on public.mantenimientos_programados for insert to authenticated
  with check (public.current_user_role() in ('administrador', 'jefe_taller'));
create policy mant_prog_update on public.mantenimientos_programados for update to authenticated
  using (public.current_user_role() in ('administrador', 'jefe_taller'))
  with check (public.current_user_role() in ('administrador', 'jefe_taller'));
create policy mant_prog_delete on public.mantenimientos_programados for delete to authenticated
  using (public.current_user_role() in ('administrador', 'jefe_taller'));

-- ── ordenes_trabajo ─────────────────────────────────────────────────
-- tecnico: solo ve/actualiza las OT que tiene asignadas. admin/jefe_taller: todo.
create policy ot_select on public.ordenes_trabajo for select to authenticated
  using (
    public.current_user_role() in ('administrador', 'jefe_taller')
    or (public.current_user_role() = 'tecnico' and tecnico_asignado_id = auth.uid())
  );
create policy ot_insert on public.ordenes_trabajo for insert to authenticated
  with check (public.current_user_role() in ('administrador', 'jefe_taller'));
create policy ot_update on public.ordenes_trabajo for update to authenticated
  using (
    public.current_user_role() in ('administrador', 'jefe_taller')
    or (public.current_user_role() = 'tecnico' and tecnico_asignado_id = auth.uid())
  )
  with check (
    public.current_user_role() in ('administrador', 'jefe_taller')
    or (public.current_user_role() = 'tecnico' and tecnico_asignado_id = auth.uid())
  );
create policy ot_delete on public.ordenes_trabajo for delete to authenticated
  using (public.current_user_role() in ('administrador', 'jefe_taller'));

-- ── novedades ───────────────────────────────────────────────────────
-- todos leen; todos pueden reportar (insert); solo admin/jefe_taller editan/borran.
create policy novedades_select on public.novedades for select to authenticated using (true);
create policy novedades_insert on public.novedades for insert to authenticated
  with check (reportado_por = auth.uid() or public.current_user_role() in ('administrador', 'jefe_taller'));
create policy novedades_update on public.novedades for update to authenticated
  using (public.current_user_role() in ('administrador', 'jefe_taller'))
  with check (public.current_user_role() in ('administrador', 'jefe_taller'));
create policy novedades_delete on public.novedades for delete to authenticated
  using (public.current_user_role() in ('administrador', 'jefe_taller'));

-- ── tareas_ot ───────────────────────────────────────────────────────
create policy tareas_ot_select on public.tareas_ot for select to authenticated
  using (
    public.current_user_role() in ('administrador', 'jefe_taller')
    or orden_trabajo_id in (select id from public.ordenes_trabajo where tecnico_asignado_id = auth.uid())
  );
create policy tareas_ot_insert on public.tareas_ot for insert to authenticated
  with check (public.current_user_role() in ('administrador', 'jefe_taller'));
create policy tareas_ot_update on public.tareas_ot for update to authenticated
  using (
    public.current_user_role() in ('administrador', 'jefe_taller')
    or orden_trabajo_id in (select id from public.ordenes_trabajo where tecnico_asignado_id = auth.uid())
  )
  with check (
    public.current_user_role() in ('administrador', 'jefe_taller')
    or orden_trabajo_id in (select id from public.ordenes_trabajo where tecnico_asignado_id = auth.uid())
  );
create policy tareas_ot_delete on public.tareas_ot for delete to authenticated
  using (public.current_user_role() in ('administrador', 'jefe_taller'));

-- ── repuestos / movimientos_stock ──────────────────────────────────
create policy repuestos_select on public.repuestos for select to authenticated using (true);
create policy repuestos_write on public.repuestos for insert to authenticated
  with check (public.current_user_role() in ('administrador', 'jefe_taller'));
create policy repuestos_update on public.repuestos for update to authenticated
  using (public.current_user_role() in ('administrador', 'jefe_taller'))
  with check (public.current_user_role() in ('administrador', 'jefe_taller'));
create policy repuestos_delete on public.repuestos for delete to authenticated
  using (public.current_user_role() in ('administrador', 'jefe_taller'));

create policy mov_stock_select on public.movimientos_stock for select to authenticated using (true);
create policy mov_stock_insert on public.movimientos_stock for insert to authenticated
  with check (public.current_user_role() in ('administrador', 'jefe_taller'));
create policy mov_stock_update on public.movimientos_stock for update to authenticated
  using (public.current_user_role() in ('administrador', 'jefe_taller'))
  with check (public.current_user_role() in ('administrador', 'jefe_taller'));
create policy mov_stock_delete on public.movimientos_stock for delete to authenticated
  using (public.current_user_role() in ('administrador', 'jefe_taller'));

-- ── archivos ────────────────────────────────────────────────────────
-- lectura abierta a autenticados; insercion abierta a los 3 roles (fotos/documentos);
-- borrado restringido a admin/jefe_taller.
create policy archivos_select on public.archivos for select to authenticated using (true);
create policy archivos_insert on public.archivos for insert to authenticated
  with check (public.current_user_role() in ('administrador', 'jefe_taller', 'tecnico'));
create policy archivos_delete on public.archivos for delete to authenticated
  using (public.current_user_role() in ('administrador', 'jefe_taller'));

-- ── historial_vehiculo ─────────────────────────────────────────────
-- solo lectura desde la app; las filas las insertan los triggers (0011) via security definer implicito de la sesion.
create policy historial_select on public.historial_vehiculo for select to authenticated using (true);
create policy historial_insert on public.historial_vehiculo for insert to authenticated with check (true);
