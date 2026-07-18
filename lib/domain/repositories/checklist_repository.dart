import '../entities/checklist.dart';
import '../entities/checklist_item.dart';

abstract class ChecklistRepository {
  Future<List<Checklist>> getAll();
  Future<Checklist?> getById(String id);
  Future<Checklist> upsert(Checklist checklist);
  Future<void> delete(String id);

  /// Items plantilla del checklist (orden_trabajo_id IS NULL).
  Future<List<ChecklistItem>> getItems(String checklistId);
  Future<ChecklistItem> upsertItem(ChecklistItem item);
  Future<void> deleteItem(String itemId);

  /// Inserta varios items de una sola vez (para cargar plantillas).
  Future<void> insertItems(List<ChecklistItem> items);
}
