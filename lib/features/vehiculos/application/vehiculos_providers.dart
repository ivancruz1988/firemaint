import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/orden_trabajo.dart';
import '../../../domain/entities/vehiculo.dart';
import '../../../domain/repositories/vehiculo_repository.dart';

final vehiculoFiltroProvider = StateProvider<VehiculoFiltro>((ref) => const VehiculoFiltro());

final vehiculosListProvider = FutureProvider<List<Vehiculo>>((ref) {
  final filtro = ref.watch(vehiculoFiltroProvider);
  return ref.watch(vehiculoRepositoryProvider).search(filtro);
});

final vehiculoByIdProvider = FutureProvider.family<Vehiculo?, String>((ref, id) {
  return ref.watch(vehiculoRepositoryProvider).getById(id);
});

/// Historial de servicio de la ficha del vehiculo: todas sus OT, mas
/// reciente primero (ya viene ordenado asi del repositorio).
final ordenesTrabajoPorVehiculoProvider = FutureProvider.family<List<OrdenTrabajo>, String>((
  ref,
  vehiculoId,
) {
  return ref.watch(ordenTrabajoRepositoryProvider).getByVehiculo(vehiculoId);
});
