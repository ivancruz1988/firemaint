import '../entities/enums.dart';
import '../entities/vehiculo.dart';

class VehiculoFiltro {
  final String? texto;
  final TipoVehiculo? tipo;
  final EstadoVehiculo? estado;

  const VehiculoFiltro({this.texto, this.tipo, this.estado});
}

class VehiculosKpis {
  final int operativos;
  final int fueraDeServicio;

  const VehiculosKpis({required this.operativos, required this.fueraDeServicio});
}

abstract class VehiculoRepository {
  Future<List<Vehiculo>> search(VehiculoFiltro filtro);
  Future<Vehiculo?> getById(String id);
  Future<Vehiculo> upsert(Vehiculo vehiculo);
  Future<void> delete(String id);
  Future<VehiculosKpis> getKpis();
}
