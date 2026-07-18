import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/mantenimiento_programado.dart';
import '../../domain/repositories/mantenimiento_programado_repository.dart';

class SupabaseMantenimientoProgramadoRepository implements MantenimientoProgramadoRepository {
  SupabaseMantenimientoProgramadoRepository(this._client);

  final SupabaseClient _client;

  MantenimientoProgramado _fromMap(Map<String, dynamic> map) {
    return MantenimientoProgramado(
      id: map['id'] as String,
      vehiculoId: map['vehiculo_id'] as String,
      checklistId: map['checklist_id'] as String?,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String?,
      frecuencia: Frecuencia.fromDb(map['frecuencia'] as String),
      proximaFecha: DateTime.parse(map['proxima_fecha'] as String),
      ultimaFechaEjecucion: map['ultima_fecha_ejecucion'] == null
          ? null
          : DateTime.parse(map['ultima_fecha_ejecucion'] as String),
      activo: map['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> _toMap(MantenimientoProgramado m) {
    return {
      'vehiculo_id': m.vehiculoId,
      'checklist_id': m.checklistId,
      'nombre': m.nombre,
      'descripcion': m.descripcion,
      'frecuencia': m.frecuencia.toDb(),
      'proxima_fecha': m.proximaFecha.toIso8601String().substring(0, 10),
      'ultima_fecha_ejecucion': m.ultimaFechaEjecucion?.toIso8601String().substring(0, 10),
      'activo': m.activo,
    };
  }

  @override
  Future<List<MantenimientoProgramado>> getAll() async {
    final rows =
        await _client.from('mantenimientos_programados').select().order('proxima_fecha');
    return rows.map(_fromMap).toList();
  }

  @override
  Future<List<MantenimientoProgramado>> getByVehiculo(String vehiculoId) async {
    final rows = await _client
        .from('mantenimientos_programados')
        .select()
        .eq('vehiculo_id', vehiculoId)
        .order('proxima_fecha');
    return rows.map(_fromMap).toList();
  }

  @override
  Future<List<MantenimientoProgramado>> getProximosAVencer() async {
    final rows = await _client
        .from('mantenimientos_programados')
        .select()
        .eq('activo', true)
        .order('proxima_fecha');
    return rows.map(_fromMap).toList();
  }

  @override
  Future<MantenimientoProgramado?> getById(String id) async {
    final row =
        await _client.from('mantenimientos_programados').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return _fromMap(row);
  }

  @override
  Future<MantenimientoProgramado> upsert(MantenimientoProgramado mantenimiento) async {
    final map = _toMap(mantenimiento);
    if (mantenimiento.id.isEmpty) {
      final row =
          await _client.from('mantenimientos_programados').insert(map).select().single();
      return _fromMap(row);
    }
    final row = await _client
        .from('mantenimientos_programados')
        .update(map)
        .eq('id', mantenimiento.id)
        .select()
        .single();
    return _fromMap(row);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('mantenimientos_programados').delete().eq('id', id);
  }
}
