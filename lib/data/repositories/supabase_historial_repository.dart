import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/historial_cambio_estado.dart';
import '../../domain/repositories/historial_repository.dart';

class SupabaseHistorialRepository implements HistorialRepository {
  SupabaseHistorialRepository(this._client);

  final SupabaseClient _client;

  HistorialCambioEstado _fromMap(Map<String, dynamic> map) {
    return HistorialCambioEstado(
      id: map['id'] as String,
      ordenTrabajoId: map['orden_trabajo_id'] as String,
      estadoAnterior: map['estado_anterior'] as String?,
      estadoNuevo: map['estado_nuevo'] as String,
      fechaCambio: DateTime.parse(map['fecha_cambio'] as String),
      usuarioNombre: map['usuario_nombre'] as String?,
      observacion: map['observacion'] as String?,
    );
  }

  EstadisticasTiempos _estadisticasFromMap(Map<String, dynamic> map) {
    return EstadisticasTiempos(
      estadoDesde: map['estado_anterior'] as String?,
      estadoHacia: map['estado_nuevo'] as String,
      cantidadTransiciones: (map['cantidad_transiciones'] as num).toInt(),
      promedioHoras: (map['promedio_horas'] as num?)?.toDouble(),
      minimoHoras: (map['minimo_horas'] as num?)?.toDouble(),
      maximoHoras: (map['maximo_horas'] as num?)?.toDouble(),
      promedioDias: (map['promedio_dias'] as num?)?.toDouble(),
    );
  }

  @override
  Future<List<HistorialCambioEstado>> obtenerHistorial(String ordenTrabajoId) async {
    try {
      final rows = await _client
          .rpc('obtener_historial_ot', params: {'p_orden_id': ordenTrabajoId}) as List;
      return rows.map((row) => _fromMap(row as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Error al obtener historial: $e');
    }
  }

  @override
  Future<EstadisticasTiempos> obtenerEstadisticas(String ordenTrabajoId) async {
    try {
      final rows = await _client
          .rpc('calcular_tiempos_promedio', params: {'p_orden_id': ordenTrabajoId}) as List;

      if (rows.isEmpty) {
        return const EstadisticasTiempos();
      }

      // Tomar el primer registro si hay múltiples
      return _estadisticasFromMap(rows.first as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  @override
  Future<List<EstadisticasTiempos>> obtenerEstadisticasGlobales() async {
    try {
      final rows = await _client
          .from('vw_estadisticas_tiempos_ot')
          .select();
      return rows.map((row) => _estadisticasFromMap(row as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Error al obtener estadísticas globales: $e');
    }
  }
}
