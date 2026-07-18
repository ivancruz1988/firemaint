import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/usuario.dart';

final usuariosProvider = FutureProvider<List<Usuario>>((ref) {
  return ref.watch(usuarioRepositoryProvider).getAll();
});
