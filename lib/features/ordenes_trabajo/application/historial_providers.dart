import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/historial_cambio_estado.dart';

final historialOrdenTrabajoProvider =
    FutureProvider.family<List<HistorialCambioEstado>, String>((ref, ordenId) async {
  return ref.watch(historialRepositoryProvider).obtenerHistorial(ordenId);
});

final estadisticasOrdenTrabajoProvider =
    FutureProvider.family<EstadisticasTiempos, String>((ref, ordenId) async {
  return ref.watch(historialRepositoryProvider).obtenerEstadisticas(ordenId);
});

final estadisticasGlobalesProvider = FutureProvider<List<EstadisticasTiempos>>((ref) async {
  return ref.watch(historialRepositoryProvider).obtenerEstadisticasGlobales();
});
