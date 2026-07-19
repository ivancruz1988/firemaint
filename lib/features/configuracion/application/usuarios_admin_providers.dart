import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/usuario.dart';

final usuariosProvider = FutureProvider<List<Usuario>>((ref) {
  return ref.watch(usuarioRepositoryProvider).getAll();
});

/// Acciones de administracion sobre usuarios. Expone el resultado como
/// AsyncValue para que la pantalla pueda mostrar el error que devuelve la base
/// (por ejemplo el del trigger al intentar autodesactivarse).
class UsuariosAdminController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> setActivo(String id, {required bool activo}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(usuarioRepositoryProvider).setActivo(id, activo: activo);
      ref.invalidate(usuariosProvider);
    });
  }
}

final usuariosAdminControllerProvider = NotifierProvider<UsuariosAdminController, AsyncValue<void>>(
  UsuariosAdminController.new,
);
