import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/orden_trabajo.dart';
import '../../auth/application/auth_providers.dart';
import 'orden_trabajo_filtro.dart';

/// Lista completa de OT: los tres roles ven todas, incluido el tecnico. La
/// restriccion por asignado quedo solo para el aviso personal del Dashboard
/// (misOrdenesPendientesProvider), no para este listado general.
final ordenesTrabajoListProvider = FutureProvider<List<OrdenTrabajo>>((ref) {
  return ref.watch(ordenTrabajoRepositoryProvider).getAll();
});

class FiltroOrdenesController extends Notifier<OrdenTrabajoFiltro> {
  @override
  OrdenTrabajoFiltro build() => const OrdenTrabajoFiltro();

  void aplicar(OrdenTrabajoFiltro filtro) => state = filtro;
  void limpiar() => state = const OrdenTrabajoFiltro();
}

final filtroOrdenesProvider = NotifierProvider<FiltroOrdenesController, OrdenTrabajoFiltro>(
  FiltroOrdenesController.new,
);

/// Lo que ve la pantalla y lo que baja la exportacion: una sola fuente, para
/// que el archivo no pueda diferir de lo que el usuario tiene a la vista.
final ordenesTrabajoFiltradasProvider = FutureProvider<List<OrdenTrabajo>>((ref) async {
  final todas = await ref.watch(ordenesTrabajoListProvider.future);
  final filtro = ref.watch(filtroOrdenesProvider);
  return todas.where(filtro.aplica).toList();
});

/// Anios presentes en el historial, para poblar el desplegable sin inventar
/// rangos fijos.
final aniosConOrdenesProvider = FutureProvider<List<int>>((ref) async {
  final todas = await ref.watch(ordenesTrabajoListProvider.future);
  final anios = todas.map((ot) => ot.fechaCreacion.year).toSet().toList();
  anios.sort((a, b) => b.compareTo(a));
  return anios;
});

final ordenTrabajoByIdProvider = FutureProvider.family<OrdenTrabajo?, String>((ref, id) {
  return ref.watch(ordenTrabajoRepositoryProvider).getById(id);
});

/// Ordenes asignadas al usuario logueado que siguen abiertas.
///
/// Alimenta el aviso del Dashboard y el globo del menu de Ordenes. Aplica a
/// cualquier rol: a un jefe de taller tambien pueden asignarle trabajo.
final misOrdenesPendientesProvider = FutureProvider<List<OrdenTrabajo>>((ref) async {
  final authUser = ref.watch(currentAuthUserProvider);
  if (authUser == null) return const [];

  final asignadas = await ref.watch(ordenTrabajoRepositoryProvider).getAsignadasA(authUser.id);
  return asignadas.where((ot) => ot.estado.estaAbierta).toList();
});
