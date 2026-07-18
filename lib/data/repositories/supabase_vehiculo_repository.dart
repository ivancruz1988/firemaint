import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/vehiculo.dart';
import '../../domain/repositories/vehiculo_repository.dart';

class SupabaseVehiculoRepository implements VehiculoRepository {
  SupabaseVehiculoRepository(this._client);

  final SupabaseClient _client;

  Vehiculo _fromMap(Map<String, dynamic> map) {
    return Vehiculo(
      id: map['id'] as String,
      numeroInterno: map['numero_interno'] as String,
      dominio: map['dominio'] as String?,
      marca: map['marca'] as String,
      modelo: map['modelo'] as String,
      anio: map['anio'] as int?,
      tipo: TipoVehiculo.fromDb(map['tipo'] as String),
      kilometraje: (map['kilometraje'] as num?)?.toDouble() ?? 0,
      horasBomba: (map['horas_bomba'] as num?)?.toDouble() ?? 0,
      fechaAlta: DateTime.parse(map['fecha_alta'] as String),
      estadoOperativo: EstadoVehiculo.fromDb(map['estado_operativo'] as String),
      observaciones: map['observaciones'] as String?,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
      fechaModificacion: DateTime.parse(map['fecha_modificacion'] as String),
    );
  }

  Map<String, dynamic> _toMap(Vehiculo vehiculo) {
    return {
      'numero_interno': vehiculo.numeroInterno,
      'dominio': vehiculo.dominio,
      'marca': vehiculo.marca,
      'modelo': vehiculo.modelo,
      'anio': vehiculo.anio,
      'tipo': vehiculo.tipo.toDb(),
      'kilometraje': vehiculo.kilometraje,
      'horas_bomba': vehiculo.horasBomba,
      'fecha_alta': vehiculo.fechaAlta.toIso8601String().substring(0, 10),
      'estado_operativo': vehiculo.estadoOperativo.toDb(),
      'observaciones': vehiculo.observaciones,
    };
  }

  @override
  Future<List<Vehiculo>> search(VehiculoFiltro filtro) async {
    var query = _client.from('vehiculos').select();

    if (filtro.tipo != null) {
      query = query.eq('tipo', filtro.tipo!.toDb());
    }
    if (filtro.estado != null) {
      query = query.eq('estado_operativo', filtro.estado!.toDb());
    }
    if (filtro.texto != null && filtro.texto!.trim().isNotEmpty) {
      final texto = filtro.texto!.trim();
      query = query.or(
        'numero_interno.ilike.%$texto%,dominio.ilike.%$texto%,marca.ilike.%$texto%,modelo.ilike.%$texto%',
      );
    }

    final rows = await query.order('numero_interno');
    return rows.map(_fromMap).toList();
  }

  @override
  Future<Vehiculo?> getById(String id) async {
    final row = await _client.from('vehiculos').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return _fromMap(row);
  }

  @override
  Future<Vehiculo> upsert(Vehiculo vehiculo) async {
    final isNuevo = vehiculo.id.isEmpty;
    final map = _toMap(vehiculo);

    if (isNuevo) {
      final row = await _client.from('vehiculos').insert(map).select().single();
      return _fromMap(row);
    }

    final row = await _client.from('vehiculos').update(map).eq('id', vehiculo.id).select().single();
    return _fromMap(row);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('vehiculos').delete().eq('id', id);
  }

  @override
  Future<VehiculosKpis> getKpis() async {
    final operativos = await _client
        .from('vehiculos')
        .select('id')
        .eq('estado_operativo', EstadoVehiculo.operativo.toDb())
        .count(CountOption.exact);
    final fueraDeServicio = await _client
        .from('vehiculos')
        .select('id')
        .eq('estado_operativo', EstadoVehiculo.fueraDeServicio.toDb())
        .count(CountOption.exact);

    return VehiculosKpis(operativos: operativos.count, fueraDeServicio: fueraDeServicio.count);
  }
}
