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
      await ref.read(supabaseClientProvider).auth.signInWithPassword(
            email: email,
            password: password,
          );
    });
  }

  Future<void> signOut() async {
    await ref.read(supabaseClientProvider).auth.signOut();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);
