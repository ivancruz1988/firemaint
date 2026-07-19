-- Correcciones de la revision de seguridad.
--
-- 1. El historial de vehiculos es el registro de auditoria del taller, pero
--    la policy historial_insert permitia que cualquier usuario autenticado
--    insertara eventos a mano, es decir, falsificar el historial. La policy
--    existia solo porque los triggers de 0011 corren como el usuario de la
--    sesion. Se les da SECURITY DEFINER (insertan con permisos propios) y se
--    elimina la policy abierta.
--
-- 2. El trigger que protege usuarios no cubria el email: un usuario podia
--    cambiar el email de su propia fila de perfil, desincronizandolo del real
--    (auth.users) y mostrando una direccion ajena en pantalla.

-- ── 1. Historial: triggers con permiso propio y puerta cerrada ──────

create or replace function public.log_historial_ot()
returns trigger language plpgsql security definer set search_path = public as $$
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

create or replace function public.log_historial_novedad()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.historial_vehiculo(vehiculo_id, tipo_evento, novedad_id, descripcion, usuario_creacion)
  values (new.vehiculo_id, 'novedad', new.id, new.tipo || ' - ' || new.titulo, auth.uid());
  return new;
end;
$$;

create or replace function public.log_historial_estado_vehiculo()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.estado_operativo is distinct from old.estado_operativo then
    insert into public.historial_vehiculo(vehiculo_id, tipo_evento, descripcion, usuario_creacion)
    values (new.id, 'cambio_estado', 'Estado cambiado a ' || new.estado_operativo, auth.uid());
  end if;
  return new;
end;
$$;

drop policy if exists historial_insert on public.historial_vehiculo;

-- ── 2. Usuarios: el email tambien queda protegido ───────────────────

create or replace function public.proteger_campos_sensibles_usuario()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if coalesce(public.current_user_role(), '') <> 'administrador' then
    if new.activo is distinct from old.activo then
      raise exception 'Solo un administrador puede activar o desactivar usuarios';
    end if;
    if new.rol_id is distinct from old.rol_id then
      raise exception 'Solo un administrador puede cambiar el rol de un usuario';
    end if;
    -- El email del perfil tiene que reflejar el de la cuenta (auth.users):
    -- dejarlo editable permitiria mostrar una direccion ajena en pantalla.
    if new.email is distinct from old.email then
      raise exception 'El correo no se puede modificar desde el perfil';
    end if;
  end if;

  if old.activo and not new.activo and new.id = auth.uid() then
    raise exception 'No podes desactivar tu propio usuario';
  end if;

  return new;
end;
$$;
