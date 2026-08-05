import '../entities/historial_ot.dart';

abstract class HistorialOtRepository {
  Future<List<HistorialOt>> getByOrdenTrabajo(String ordenTrabajoId);
}
