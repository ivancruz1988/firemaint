import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/supabase/supabase_client_provider.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/usuario.dart';

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

final currentAuthUserProvider = Provider<User?>((ref) {
  final fromStream = ref.watch(authStateChangesProvider).value?.session?.user;
  return fromStream ?? ref.watch(supabaseClientProvider).auth.currentUser;
});

final currentUsuarioProvider = FutureProvider<Usuario?>((ref) async {
  final authUser = ref.watch(currentAuthUserProvider);
  if (authUser == null) return null;
  return ref.watch(usuarioRepositoryProvider).getById(authUser.id);
});

final currentRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(currentUsuarioProvider).value?.rol;
});

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signInWithPassword(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(supabaseClientProvider)
          .auth
          .signInWithPassword(email: email, password: password);
    });
  }

  Future<void> signOut() async {
    await ref.read(supabaseClientProvider).auth.signOut();
  }

  /// Cambia la contrasena del usuario logueado (tipicamente para reemplazar la
  /// provisoria que le asigno el administrador al darlo de alta).
  Future<void> cambiarPassword({required String actual, required String nueva}) async {
    final client = ref.read(supabaseClientProvider);
    final email = client.auth.currentUser?.email;
    if (email == null) throw Exception('No hay una sesion activa');

    // Se revalida la contrasena actual antes de cambiarla: sin esto, cualquiera
    // que encuentre el equipo con la sesion abierta podria dejar al usuario
    // afuera de su propia cuenta.
    await client.auth.signInWithPassword(email: email, password: actual);
    await client.auth.updateUser(UserAttributes(password: nueva));
  }
}

final authControllerProvider = NotifierProvider<AuthController, AsyncValue<void>>(
  AuthController.new,
);
