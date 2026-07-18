import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/checklist.dart';
import '../../domain/entities/checklist_item.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/checklist_repository.dart';

class SupabaseChecklistRepository implements ChecklistRepository {
  SupabaseChecklistRepository(this._client);

  final SupabaseClient _client;

  Checklist _fromMap(Map<String, dynamic> map) {
    return Checklist(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String?,
      tipoVehiculo: map['tipo_vehiculo'] as String?,
      activo: map['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> _toMap(Checklist c) {
    return {
      'nombre': c.nombre,
      'descripcion': c.descripcion,
      'tipo_vehiculo': c.tipoVehiculo,
      'activo': c.activo,
    };
  }

  ChecklistItem _itemFromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] as String,
      checklistId: map['checklist_id'] as String,
      ordenTrabajoId: map['orden_trabajo_id'] as String?,
      categoria: map['categoria'] as String?,
      descripcion: map['descripcion'] as String,
      orden: (map['orden'] as num?)?.toInt() ?? 0,
      resultado: ResultadoChecklistItem.fromDb(map['resultado'] as String?),
      observacion: map['observacion'] as String?,
    );
  }

  Map<String, dynamic> _itemToMap(ChecklistItem item) {
    return {
      'checklist_id': item.checklistId,
      'orden_trabajo_id': item.ordenTrabajoId,
      'categoria': item.categoria,
      'descripcion': item.descripcion,
      'orden': item.orden,
      'resultado': item.resultado?.toDb(),
      'observacion': item.observacion,
    };
  }

  @override
  Future<List<Checklist>> getAll() async {
    final rows = await _client.from('checklists').select().order('nombre');
    return rows.map(_fromMap).toList();
  }

  @override
  Future<Checklist?> getById(String id) async {
    final row = await _client.from('checklists').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return _fromMap(row);
  }

  @override
  Future<Checklist> upsert(Checklist checklist) async {
    final map = _toMap(checklist);
    if (checklist.id.isEmpty) {
      final row = await _client.from('checklists').insert(map).select().single();
      return _fromMap(row);
    }
    final row =
        await _client.from('checklists').update(map).eq('id', checklist.id).select().single();
    return _fromMap(row);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('checklists').delete().eq('id', id);
  }

  @override
  Future<List<ChecklistItem>> getItems(String checklistId) async {
    final rows = await _client
        .from('checklist_items')
        .select()
        .eq('checklist_id', checklistId)
        .isFilter('orden_trabajo_id', null)
        .order('orden');
    return rows.map(_itemFromMap).toList();
  }

  @override
  Future<ChecklistItem> upsertItem(ChecklistItem item) async {
    final map = _itemToMap(item);
    if (item.id.isEmpty) {
      final row = await _client.from('checklist_items').insert(map).select().single();
      return _itemFromMap(row);
    }
    final row =
        await _client.from('checklist_items').update(map).eq('id', item.id).select().single();
    return _itemFromMap(row);
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await _client.from('checklist_items').delete().eq('id', itemId);
  }

  @override
  Future<void> insertItems(List<ChecklistItem> items) async {
    if (items.isEmpty) return;
    await _client.from('checklist_items').insert(items.map(_itemToMap).toList());
  }
}
