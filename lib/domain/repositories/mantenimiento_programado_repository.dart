import '../entities/mantenimiento_programado.dart';

abstract class MantenimientoProgramadoRepository {
  Future<List<MantenimientoProgramado>> getAll();
  Future<List<MantenimientoProgramado>> getByVehiculo(String vehiculoId);
  Future<List<MantenimientoProgramado>> getProximosAVencer();
  Future<MantenimientoProgramado?> getById(String id);
  Future<MantenimientoProgramado> upsert(MantenimientoProgramado mantenimiento);
  Future<void> delete(String id);
}
