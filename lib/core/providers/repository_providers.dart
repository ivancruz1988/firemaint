import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/supabase_checklist_repository.dart';
import '../../data/repositories/supabase_mantenimiento_programado_repository.dart';
import '../../data/repositories/supabase_novedad_repository.dart';
import '../../data/repositories/supabase_orden_trabajo_repository.dart';
import '../../data/repositories/supabase_repuesto_repository.dart';
import '../../data/repositories/supabase_usuario_repository.dart';
import '../../data/repositories/supabase_vehiculo_archivo_repository.dart';
import '../../data/repositories/supabase_vehiculo_repository.dart';
import '../../domain/repositories/checklist_repository.dart';
import '../../domain/repositories/mantenimiento_programado_repository.dart';
import '../../domain/repositories/novedad_repository.dart';
import '../../domain/repositories/orden_trabajo_repository.dart';
import '../../domain/repositories/repuesto_repository.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../../domain/repositories/vehiculo_archivo_repository.dart';
import '../../domain/repositories/vehiculo_repository.dart';
import '../supabase/supabase_client_provider.dart';

final usuarioRepositoryProvider = Provider<UsuarioRepository>((ref) {
  return SupabaseUsuarioRepository(ref.watch(supabaseClientProvider));
});

final vehiculoRepositoryProvider = Provider<VehiculoRepository>((ref) {
  return SupabaseVehiculoRepository(ref.watch(supabaseClientProvider));
});

final vehiculoArchivoRepositoryProvider = Provider<VehiculoArchivoRepository>((ref) {
  return SupabaseVehiculoArchivoRepository(ref.watch(supabaseClientProvider));
});

final ordenTrabajoRepositoryProvider = Provider<OrdenTrabajoRepository>((ref) {
  return SupabaseOrdenTrabajoRepository(ref.watch(supabaseClientProvider));
});

final novedadRepositoryProvider = Provider<NovedadRepository>((ref) {
  return SupabaseNovedadRepository(ref.watch(supabaseClientProvider));
});

final repuestoRepositoryProvider = Provider<RepuestoRepository>((ref) {
  return SupabaseRepuestoRepository(ref.watch(supabaseClientProvider));
});

final checklistRepositoryProvider = Provider<ChecklistRepository>((ref) {
  return SupabaseChecklistRepository(ref.watch(supabaseClientProvider));
});

final mantenimientoProgramadoRepositoryProvider =
    Provider<MantenimientoProgramadoRepository>((ref) {
  return SupabaseMantenimientoProgramadoRepository(ref.watch(supabaseClientProvider));
});
