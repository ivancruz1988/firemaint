import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/vehiculo.dart';
import '../../domain/repositories/vehiculo_repository.dart';
import 'repository_providers.dart';

/// Lista completa de vehiculos para poblar dropdowns en formularios de otros
/// modulos (OT, novedades, mantenimiento). Independiente del filtro de la
/// pantalla de vehiculos.
final vehiculosLookupProvider = FutureProvider<List<Vehiculo>>((ref) {
  return ref.watch(vehiculoRepositoryProvider).search(const VehiculoFiltro());
});

/// Mapa id -> Vehiculo para mostrar el nombre del vehiculo en listados de OT,
/// novedades, etc. sin hacer un join por fila.
final vehiculosMapProvider = FutureProvider<Map<String, Vehiculo>>((ref) async {
  final vehiculos = await ref.watch(vehiculosLookupProvider.future);
  return {for (final v in vehiculos) v.id: v};
});

/// Todos los usuarios (solo legible por admin/jefe_taller segun RLS).
final usuariosLookupProvider = FutureProvider<List<Usuario>>((ref) {
  return ref.watch(usuarioRepositoryProvider).getAll();
});

/// Usuarios con rol tecnico, para asignar ordenes de trabajo.
final tecnicosProvider = FutureProvider<List<Usuario>>((ref) async {
  final usuarios = await ref.watch(usuariosLookupProvider.future);
  return usuarios.where((u) => u.rol == UserRole.tecnico).toList();
});

/// Mapa id -> Usuario para mostrar el nombre del tecnico asignado.
final usuariosMapProvider = FutureProvider<Map<String, Usuario>>((ref) async {
  final usuarios = await ref.watch(usuariosLookupProvider.future);
  return {for (final u in usuarios) u.id: u};
});
