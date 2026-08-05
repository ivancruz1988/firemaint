import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/historial_ot.dart';
import '../../domain/repositories/historial_ot_repository.dart';

class SupabaseHistorialOtRepository implements HistorialOtRepository {
  SupabaseHistorialOtRepository(this._client);

  final SupabaseClient _client;

  HistorialOt _fromMap(Map<String, dynamic> map) {
    return HistorialOt(
      id: map['id'] as String,
      ordenTrabajoId: map['orden_trabajo_id'] as String,
      evento: EventoHistorialOt.fromDb(map['evento'] as String),
      descripcion: map['descripcion'] as String,
      estadoAnterior: map['estado_anterior'] as String?,
      estadoNuevo: map['estado_nuevo'] as String?,
      novedadId: map['novedad_id'] as String?,
      fechaEvento: DateTime.parse(map['fecha_evento'] as String),
    );
  }

  @override
  Future<List<HistorialOt>> getByOrdenTrabajo(String ordenTrabajoId) async {
    final rows = await _client
        .from('historial_ot')
        .select()
        .eq('orden_trabajo_id', ordenTrabajoId)
        .order('fecha_evento', ascending: false);
    return rows.map(_fromMap).toList();
  }
}
