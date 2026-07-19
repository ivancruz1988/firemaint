# Tareas pendientes de FireMaint

## 🔴 SQL en Supabase (para que las notificaciones por mail funcionen)

1. Correr el SQL combinado de las migraciones 0015 a 0018.
   Está guardado en el proyecto en:
   - `supabase/migrations/0015_notificar_asignacion_ot.sql`
   - `supabase/migrations/0016_endurecer_seguridad.sql`
   - `supabase/migrations/0017_alerta_mantenimiento_vencido.sql`
   - `supabase/migrations/0018_stock_atomico_y_alerta.sql`

   Se corren en Supabase → SQL Editor, en ese orden (o todas juntas, son
   seguras de re-correr aunque una parte ya este aplicada).

2. Cargar `config_notificaciones` con la URL del proyecto y la
   service_role_key (clave secreta, nunca pegarla en el chat). El INSERT
   de ejemplo esta en el historial de la conversacion del 2026-07-19.

3. Completar los 4 pasos de Brevo (crear cuenta, verificar remitente,
   sacar API key, cargarla en Supabase) para que los mails realmente salgan.

4. Deployar en Supabase Edge Functions (con esos nombres exactos):
   - `notificar-asignacion` (asignar OT a un tecnico)
   - `notificar-mantenimientos-vencidos` (cron diario 8am)
   - `notificar-stock-bajo` (repuesto cruza el minimo)

## 🟡 Mejoras de sistema sugeridas, sin empezar

- Monitoreo de errores en produccion (Sentry) — requiere crear cuenta
- Recompilar el APK de Android (esta desactualizado hace varias semanas:
  sin tema oscuro, sin logo, sin cambio de contrasena, sin nada reciente)
- Exportar a Excel/PDF en Vehiculos y Repuestos (hoy solo existe en
  Ordenes de Trabajo)

## ✅ Ya hecho y en produccion (Netlify)

- Tema oscuro, logo del cuartel, nombre "Sistema de Gestion de Automotores"
- Alta/edicion/baja logica de usuarios, cambio de contrasena
- Fotos en novedades
- Filtros y exportacion Excel/PDF en Ordenes de Trabajo
- Manejo de perdida de conexion (nivel basico)
- Avisos de mantenimiento vencido y stock bajo (falta el SQL de arriba)
- Correccion de condicion de carrera en movimientos de stock
- 27 tests automaticos
- Revision de seguridad completa
