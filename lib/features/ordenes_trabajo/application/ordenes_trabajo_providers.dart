import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/orden_trabajo.dart';
import '../../auth/application/auth_providers.dart';

/// Lista de OT segun el rol: administrador y jefe_taller ven todas; el tecnico
/// solo ve las asignadas a el.
final ordenesTrabajoListProvider = FutureProvider<List<OrdenTrabajo>>((ref) async {
  final repo = ref.watch(ordenTrabajoRepositoryProvider);
  final rol = ref.watch(currentRoleProvider);
  final authUser = ref.watch(currentAuthUserProvider);

  if (rol == UserRole.tecnico && authUser != null) {
    return repo.getAsignadasA(authUser.id);
  }
  return repo.getAll();
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
