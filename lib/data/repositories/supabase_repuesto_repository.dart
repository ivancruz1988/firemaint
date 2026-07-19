import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/movimiento_stock.dart';
import '../../domain/entities/repuesto.dart';
import '../../domain/repositories/repuesto_repository.dart';

class SupabaseRepuestoRepository implements RepuestoRepository {
  SupabaseRepuestoRepository(this._client);

  final SupabaseClient _client;

  Repuesto _fromMap(Map<String, dynamic> map) {
    return Repuesto(
      id: map['id'] as String,
      codigo: map['codigo'] as String,
      descripcion: map['descripcion'] as String,
      stock: (map['stock'] as num?)?.toDouble() ?? 0,
      stockMinimo: (map['stock_minimo'] as num?)?.toDouble() ?? 0,
      ubicacion: map['ubicacion'] as String?,
      unidadMedida: map['unidad_medida'] as String? ?? 'unidad',
      costoUnitario: (map['costo_unitario'] as num?)?.toDouble(),
      activo: map['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> _toMap(Repuesto r) {
    return {
      'codigo': r.codigo,
      'descripcion': r.descripcion,
      'stock': r.stock,
      'stock_minimo': r.stockMinimo,
      'ubicacion': r.ubicacion,
      'unidad_medida': r.unidadMedida,
      'costo_unitario': r.costoUnitario,
      'activo': r.activo,
    };
  }

  MovimientoStock _movFromMap(Map<String, dynamic> map) {
    return MovimientoStock(
      id: map['id'] as String,
      repuestoId: map['repuesto_id'] as String,
      tipoMovimiento: TipoMovimientoStock.fromDb(map['tipo_movimiento'] as String),
      cantidad: (map['cantidad'] as num).toDouble(),
      ordenTrabajoId: map['orden_trabajo_id'] as String?,
      motivo: map['motivo'] as String?,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
    );
  }

  @override
  Future<List<Repuesto>> getAll() async {
    final rows = await _client.from('repuestos').select().order('codigo');
    return rows.map(_fromMap).toList();
  }

  @override
  Future<List<Repuesto>> getStockBajo() async {
    final rows = await _client.from('repuestos').select().order('codigo');
    return rows.map(_fromMap).where((r) => r.stockBajo).toList();
  }

  @override
  Future<Repuesto?> getById(String id) async {
    final row = await _client.from('repuestos').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return _fromMap(row);
  }

  @override
  Future<Repuesto> upsert(Repuesto repuesto) async {
    final map = _toMap(repuesto);
    if (repuesto.id.isEmpty) {
      final row = await _client.from('repuestos').insert(map).select().single();
      return _fromMap(row);
    }
    final row = await _client.from('repuestos').update(map).eq('id', repuesto.id).select().single();
    return _fromMap(row);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('repuestos').delete().eq('id', id);
  }

  @override
  Future<List<MovimientoStock>> getMovimientos(String repuestoId) async {
    final rows = await _client
        .from('movimientos_stock')
        .select()
        .eq('repuesto_id', repuestoId)
        .order('fecha_creacion', ascending: false);
    return rows.map(_movFromMap).toList();
  }

  @override
  Future<void> registrarMovimiento(MovimientoStock movimiento) async {
    // El recalculo del stock lo hace un trigger en la base (migracion 0018),
    // no el cliente: hacerlo aca requeria leer el stock y escribirlo en dos
    // llamadas separadas, y dos movimientos casi simultaneos del mismo
    // repuesto podian leer el mismo valor viejo y pisarse entre si.
    await _client.from('movimientos_stock').insert({
      'repuesto_id': movimiento.repuestoId,
      'tipo_movimiento': movimiento.tipoMovimiento.toDb(),
      'cantidad': movimiento.cantidad,
      'orden_trabajo_id': movimiento.ordenTrabajoId,
      'motivo': movimiento.motivo,
    });
  }
}
