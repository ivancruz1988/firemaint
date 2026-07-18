import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/orden_trabajo.dart';
import '../../domain/repositories/orden_trabajo_repository.dart';

class SupabaseOrdenTrabajoRepository implements OrdenTrabajoRepository {
  SupabaseOrdenTrabajoRepository(this._client);

  final SupabaseClient _client;

  OrdenTrabajo _fromMap(Map<String, dynamic> map) {
    return OrdenTrabajo(
      id: map['id'] as String,
      numeroOt: (map['numero_ot'] as num).toInt(),
      vehiculoId: map['vehiculo_id'] as String,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String?,
      prioridad: PrioridadOt.fromDb(map['prioridad'] as String),
      estado: EstadoOt.fromDb(map['estado'] as String),
      tecnicoAsignadoId: map['tecnico_asignado_id'] as String?,
      horasTrabajo: (map['horas_trabajo'] as num?)?.toDouble(),
      costoEstimado: (map['costo_estimado'] as num?)?.toDouble(),
      costoReal: (map['costo_real'] as num?)?.toDouble(),
      fechaInicio: map['fecha_inicio'] == null ? null : DateTime.parse(map['fecha_inicio'] as String),
      fechaFin: map['fecha_fin'] == null ? null : DateTime.parse(map['fecha_fin'] as String),
      observaciones: map['observaciones'] as String?,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
    );
  }

  Map<String, dynamic> _toMap(OrdenTrabajo ot) {
    return {
      'vehiculo_id': ot.vehiculoId,
      'titulo': ot.titulo,
      'descripcion': ot.descripcion,
      'prioridad': ot.prioridad.toDb(),
      'estado': ot.estado.toDb(),
      'tecnico_asignado_id': ot.tecnicoAsignadoId,
      'horas_trabajo': ot.horasTrabajo,
      'costo_estimado': ot.costoEstimado,
      'costo_real': ot.costoReal,
      'fecha_inicio': ot.fechaInicio?.toIso8601String(),
      'fecha_fin': ot.fechaFin?.toIso8601String(),
      'observaciones': ot.observaciones,
    };
  }

  @override
  Future<List<OrdenTrabajo>> getAll() async {
    final rows = await _client.from('ordenes_trabajo').select().order('numero_ot', ascending: false);
    return rows.map(_fromMap).toList();
  }

  @override
  Future<List<OrdenTrabajo>> getByVehiculo(String vehiculoId) async {
    final rows = await _client
        .from('ordenes_trabajo')
        .select()
        .eq('vehiculo_id', vehiculoId)
        .order('numero_ot', ascending: false);
    return rows.map(_fromMap).toList();
  }

  @override
  Future<List<OrdenTrabajo>> getAsignadasA(String tecnicoId) async {
    final rows = await _client
        .from('ordenes_trabajo')
        .select()
        .eq('tecnico_asignado_id', tecnicoId)
        .order('numero_ot', ascending: false);
    return rows.map(_fromMap).toList();
  }

  @override
  Future<OrdenTrabajo?> getById(String id) async {
    final row = await _client.from('ordenes_trabajo').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return _fromMap(row);
  }

  @override
  Future<OrdenTrabajo> upsert(OrdenTrabajo ot) async {
    final map = _toMap(ot);
    if (ot.id.isEmpty) {
      final row = await _client.from('ordenes_trabajo').insert(map).select().single();
      return _fromMap(row);
    }
    final row = await _client.from('ordenes_trabajo').update(map).eq('id', ot.id).select().single();
    return _fromMap(row);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('ordenes_trabajo').delete().eq('id', id);
  }

  @override
  Future<OrdenesTrabajoKpis> getKpis() async {
    final pendientes = await _client
        .from('ordenes_trabajo')
        .select('id')
        .eq('estado', EstadoOt.pendiente.toDb())
        .count(CountOption.exact);
    final enProceso = await _client
        .from('ordenes_trabajo')
        .select('id')
        .eq('estado', EstadoOt.enProceso.toDb())
        .count(CountOption.exact);
    final finalizadas = await _client
        .from('ordenes_trabajo')
        .select('id')
        .eq('estado', EstadoOt.finalizada.toDb())
        .count(CountOption.exact);

    return OrdenesTrabajoKpis(
      pendientes: pendientes.count,
      enProceso: enProceso.count,
      finalizadas: finalizadas.count,
    );
  }
}
