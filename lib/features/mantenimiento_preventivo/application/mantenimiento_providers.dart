import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/mantenimiento_programado.dart';

final mantenimientosListProvider = FutureProvider<List<MantenimientoProgramado>>((ref) {
  return ref.watch(mantenimientoProgramadoRepositoryProvider).getAll();
});

final mantenimientoByIdProvider = FutureProvider.family<MantenimientoProgramado?, String>((
  ref,
  id,
) {
  return ref.watch(mantenimientoProgramadoRepositoryProvider).getById(id);
});

/// true si un plan activo ya deberia haberse hecho: la fecha programada es
/// hoy o quedo atras. proximaFecha llega como medianoche del dia programado,
/// asi que comparar contra DateTime.now() (que salvo el instante exacto de
/// medianoche siempre es mas tarde en el dia) alcanza sin normalizar horas.
bool estaVencido(MantenimientoProgramado m) => m.activo && m.proximaFecha.isBefore(DateTime.now());

/// Planes vencidos, para el aviso del Dashboard y el globo del menu. Solo
/// tiene sentido para quien puede gestionar mantenimiento (admin/jefe de
/// taller): un tecnico no tiene permiso para crear ni editar estos planes.
final mantenimientosVencidosProvider = FutureProvider<List<MantenimientoProgramado>>((ref) async {
  final todos = await ref.watch(mantenimientosListProvider.future);
  return todos.where(estaVencido).toList();
});
