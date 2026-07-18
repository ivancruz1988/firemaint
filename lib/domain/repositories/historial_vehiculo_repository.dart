import '../entities/historial_evento.dart';

/// Interfaz para Fase 2+ (historial completo con filtros). Sin implementacion todavia.
abstract class HistorialVehiculoRepository {
  Future<List<HistorialEvento>> getByVehiculo(String vehiculoId);
}
