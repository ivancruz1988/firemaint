import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/mantenimiento_programado.dart';

final mantenimientosListProvider = FutureProvider<List<MantenimientoProgramado>>((ref) {
  return ref.watch(mantenimientoProgramadoRepositoryProvider).getAll();
});

final mantenimientoByIdProvider =
    FutureProvider.family<MantenimientoProgramado?, String>((ref, id) {
  return ref.watch(mantenimientoProgramadoRepositoryProvider).getById(id);
});
