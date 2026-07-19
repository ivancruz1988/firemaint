import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/repositories/vehiculo_repository.dart';

class ReporteData {
  final int vehiculosOperativos;
  final int vehiculosEnMantenimiento;
  final int vehiculosFueraDeServicio;
  final Map<EstadoOt, int> otPorEstado;
  final int novedadesAbiertas;
  final int repuestosStockBajo;

  const ReporteData({
    required this.vehiculosOperativos,
    required this.vehiculosEnMantenimiento,
    required this.vehiculosFueraDeServicio,
    required this.otPorEstado,
    required this.novedadesAbiertas,
    required this.repuestosStockBajo,
  });

  int get totalVehiculos =>
      vehiculosOperativos + vehiculosEnMantenimiento + vehiculosFueraDeServicio;

  int get totalOt => otPorEstado.values.fold(0, (a, b) => a + b);
}

final reporteDataProvider = FutureProvider<ReporteData>((ref) async {
  final vehiculos = await ref.watch(vehiculoRepositoryProvider).search(const VehiculoFiltro());
  final ots = await ref.watch(ordenTrabajoRepositoryProvider).getAll();
  final novedades = await ref.watch(novedadRepositoryProvider).getAll();
  final repuestos = await ref.watch(repuestoRepositoryProvider).getAll();

  final otPorEstado = <EstadoOt, int>{};
  for (final estado in EstadoOt.values) {
    otPorEstado[estado] = ots.where((o) => o.estado == estado).length;
  }

  return ReporteData(
    vehiculosOperativos: vehiculos
        .where((v) => v.estadoOperativo == EstadoVehiculo.operativo)
        .length,
    vehiculosEnMantenimiento: vehiculos
        .where((v) => v.estadoOperativo == EstadoVehiculo.enMantenimiento)
        .length,
    vehiculosFueraDeServicio: vehiculos
        .where((v) => v.estadoOperativo == EstadoVehiculo.fueraDeServicio)
        .length,
    otPorEstado: otPorEstado,
    novedadesAbiertas: novedades.where((n) => n.estado == EstadoNovedad.abierta).length,
    repuestosStockBajo: repuestos.where((r) => r.stockBajo).length,
  );
});
