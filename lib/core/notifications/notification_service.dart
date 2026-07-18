/// Punto de extension para notificaciones push (Firebase Cloud Messaging).
///
/// TODO(Fase 2): reemplazar por una implementacion real con firebase_core +
/// firebase_messaging cuando se aborde el modulo de Notificaciones. Por ahora
/// es un no-op para que el resto de la app pueda depender de la interfaz sin
/// atar el proyecto a Firebase todavia.
abstract class NotificationService {
  Future<void> init();
  Future<void> notify({required String titulo, required String cuerpo});
}

class NoopNotificationService implements NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<void> notify({required String titulo, required String cuerpo}) async {}
}
