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
