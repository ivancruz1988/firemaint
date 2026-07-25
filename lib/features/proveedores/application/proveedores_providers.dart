import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/proveedor.dart';

final proveedorBusquedaProvider = StateProvider<String>((ref) => '');

final proveedoresListProvider = FutureProvider<List<Proveedor>>((ref) {
  return ref
      .watch(proveedorRepositoryProvider)
      .getAll(busqueda: ref.watch(proveedorBusquedaProvider));
});

final proveedorByIdProvider = FutureProvider.family<Proveedor?, String>((
  ref,
  id,
) {
  return ref.watch(proveedorRepositoryProvider).getById(id);
});
