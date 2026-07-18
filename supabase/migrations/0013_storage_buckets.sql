insert into storage.buckets (id, name, public)
values ('vehiculo-adjuntos', 'vehiculo-adjuntos', false);

create policy "vehiculo_adjuntos_read" on storage.objects for select to authenticated
  using (bucket_id = 'vehiculo-adjuntos');

create policy "vehiculo_adjuntos_write" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'vehiculo-adjuntos'
    and (select public.current_user_role()) in ('administrador', 'jefe_taller', 'tecnico')
  );

create policy "vehiculo_adjuntos_delete" on storage.objects for delete to authenticated
  using (
    bucket_id = 'vehiculo-adjuntos'
    and (select public.current_user_role()) in ('administrador', 'jefe_taller')
  );

-- Convencion de path: vehiculo-adjuntos/{vehiculo_id}/{uuid()}_{nombre_original}
-- El bucket es privado: la app siempre debe leer via createSignedUrl, nunca via URL publica.
