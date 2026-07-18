import '../entities/novedad.dart';

abstract class NovedadRepository {
  Future<List<Novedad>> getAll();
  Future<List<Novedad>> getByVehiculo(String vehiculoId);
  Future<Novedad?> getById(String id);
  Future<Novedad> upsert(Novedad novedad);
  Future<void> delete(String id);
}
