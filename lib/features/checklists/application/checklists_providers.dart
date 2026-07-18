import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/checklist.dart';
import '../../../domain/entities/checklist_item.dart';

final checklistsListProvider = FutureProvider<List<Checklist>>((ref) {
  return ref.watch(checklistRepositoryProvider).getAll();
});

final checklistByIdProvider = FutureProvider.family<Checklist?, String>((ref, id) {
  return ref.watch(checklistRepositoryProvider).getById(id);
});

final checklistItemsProvider = FutureProvider.family<List<ChecklistItem>, String>((ref, checklistId) {
  return ref.watch(checklistRepositoryProvider).getItems(checklistId);
});
