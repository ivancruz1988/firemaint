import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/movimiento_stock.dart';
import '../../../domain/entities/repuesto.dart';

final repuestosListProvider = FutureProvider<List<Repuesto>>((ref) {
  return ref.watch(repuestoRepositoryProvider).getAll();
});

final repuestoByIdProvider = FutureProvider.family<Repuesto?, String>((ref, id) {
  return ref.watch(repuestoRepositoryProvider).getById(id);
});

final movimientosProvider = FutureProvider.family<List<MovimientoStock>, String>((ref, repuestoId) {
  return ref.watch(repuestoRepositoryProvider).getMovimientos(repuestoId);
});
