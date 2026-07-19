import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/movimiento_stock.dart';
import '../../../domain/entities/repuesto.dart';

final repuestosListProvider = FutureProvider<List<Repuesto>>((ref) {
  return ref.watch(repuestoRepositoryProvider).getAll();
});

/// Repuestos en o por debajo del stock minimo, para el aviso del Dashboard y
/// el globo del menu. Solo tiene sentido para quien gestiona el deposito
/// (admin/jefe de taller): un tecnico no puede registrar reposiciones.
final repuestosStockBajoProvider = FutureProvider<List<Repuesto>>((ref) {
  return ref.watch(repuestoRepositoryProvider).getStockBajo();
});

final repuestoByIdProvider = FutureProvider.family<Repuesto?, String>((ref, id) {
  return ref.watch(repuestoRepositoryProvider).getById(id);
});

final movimientosProvider = FutureProvider.family<List<MovimientoStock>, String>((ref, repuestoId) {
  return ref.watch(repuestoRepositoryProvider).getMovimientos(repuestoId);
});
