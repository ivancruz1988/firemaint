import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/novedad.dart';
import '../../domain/repositories/novedad_repository.dart';

class SupabaseNovedadRepository implements NovedadRepository {
  SupabaseNovedadRepository(this._client);

  final SupabaseClient _client;

  Novedad _fromMap(Map<String, dynamic> map) {
    return Novedad(
      id: map['id'] as String,
      vehiculoId: map['vehiculo_id'] as String,
      tipo: TipoNovedad.fromDb(map['tipo'] as String),
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String?,
      fechaOcurrencia: DateTime.parse(map['fecha_ocurrencia'] as String),
      estado: EstadoNovedad.fromDb(map['estado'] as String),
      ordenTrabajoId: map['orden_trabajo_id'] as String?,
      reportadoPor: map['reportado_por'] as String?,
    );
  }

  Map<String, dynamic> _toMap(Novedad novedad) {
    return {
      'vehiculo_id': novedad.vehiculoId,
      'tipo': novedad.tipo.toDb(),
      'titulo': novedad.titulo,
      'descripcion': novedad.descripcion,
      'fecha_ocurrencia': novedad.fechaOcurrencia.toIso8601String(),
      'estado': novedad.estado.toDb(),
      'orden_trabajo_id': novedad.ordenTrabajoId,
      if (novedad.reportadoPor != null) 'reportado_por': novedad.reportadoPor,
    };
  }

  @override
  Future<List<Novedad>> getAll() async {
    final rows = await _client.from('novedades').select().order('fecha_ocurrencia', ascending: false);
    return rows.map(_fromMap).toList();
  }

  @override
  Future<List<Novedad>> getByVehiculo(String vehiculoId) async {
    final rows = await _client
        .from('novedades')
        .select()
        .eq('vehiculo_id', vehiculoId)
        .order('fecha_ocurrencia', ascending: false);
    return rows.map(_fromMap).toList();
  }

  @override
  Future<Novedad?> getById(String id) async {
    final row = await _client.from('novedades').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return _fromMap(row);
  }

  @override
  Future<Novedad> upsert(Novedad novedad) async {
    final map = _toMap(novedad);
    if (novedad.id.isEmpty) {
      // reportado_por lo completa el usuario actual al crear.
      map['reportado_por'] = _client.auth.currentUser?.id;
      final row = await _client.from('novedades').insert(map).select().single();
      return _fromMap(row);
    }
    final row = await _client.from('novedades').update(map).eq('id', novedad.id).select().single();
    return _fromMap(row);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('novedades').delete().eq('id', id);
  }
}
