import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/novedad.dart';

final novedadesListProvider = FutureProvider<List<Novedad>>((ref) {
  return ref.watch(novedadRepositoryProvider).getAll();
});

final novedadByIdProvider = FutureProvider.family<Novedad?, String>((ref, id) {
  return ref.watch(novedadRepositoryProvider).getById(id);
});
