import '../entities/historial_cambio_estado.dart';

abstract class HistorialRepository {
  Future<List<HistorialCambioEstado>> obtenerHistorial(String ordenTrabajoId);
  Future<EstadisticasTiempos> obtenerEstadisticas(String ordenTrabajoId);
  Future<List<EstadisticasTiempos>> obtenerEstadisticasGlobales();
}
