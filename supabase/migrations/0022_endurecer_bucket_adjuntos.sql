-- El bucket vehiculo-adjuntos aceptaba cualquier tipo/tamano de archivo, y el
-- Content-Type quedaba a criterio del cliente (mime_type que manda la app).
-- Un archivo .html/.svg subido con Content-Type: text/html se ejecutaria si
-- alguien abre la signed URL directo en el navegador en vez de via <img> de
-- la app (XSS almacenado contra otro usuario autenticado). Restringimos a
-- los tipos que la UI ya ofrece (foto: jpg/jpeg/png; documento: pdf/doc/docx)
-- y ponemos un limite de tamano razonable para uso de guardia de bomberos.
update storage.buckets
set
  file_size_limit = 15728640, -- 15 MB
  allowed_mime_types = array[
    'image/jpeg',
    'image/png',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ]
where id = 'vehiculo-adjuntos';
