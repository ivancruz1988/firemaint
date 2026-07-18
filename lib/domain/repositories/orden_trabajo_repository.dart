import '../entities/orden_trabajo.dart';

abstract class OrdenTrabajoRepository {
  Future<List<OrdenTrabajo>> getAll();
  Future<List<OrdenTrabajo>> getByVehiculo(String vehiculoId);
  Future<List<OrdenTrabajo>> getAsignadasA(String tecnicoId);
  Future<OrdenTrabajo?> getById(String id);
  Future<OrdenTrabajo> upsert(OrdenTrabajo ot);
  Future<void> delete(String id);
  Future<OrdenesTrabajoKpis> getKpis();
}

class OrdenesTrabajoKpis {
  final int pendientes;
  final int enProceso;
  final int finalizadas;

  const OrdenesTrabajoKpis({
    required this.pendientes,
    required this.enProceso,
    required this.finalizadas,
  });
}
