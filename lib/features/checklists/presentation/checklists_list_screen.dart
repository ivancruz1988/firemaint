import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/empty_state.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../../../domain/entities/enums.dart';
import '../../auth/application/auth_providers.dart';
import '../application/checklists_providers.dart';

class ChecklistsListScreen extends ConsumerWidget {
  const ChecklistsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checklistsAsync = ref.watch(checklistsListProvider);
    final rol = ref.watch(currentRoleProvider);
    final puedeGestionar = rol == UserRole.administrador || rol == UserRole.jefeTaller;

    return Scaffold(
      appBar: AppBar(title: const Text('Checklists')),
      floatingActionButton: puedeGestionar
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/checklists/nuevo'),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo checklist'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(checklistsListProvider),
        child: checklistsAsync.when(
          data: (checklists) {
            if (checklists.isEmpty) {
              return ListView(
                children: const [
                  EmptyState(
                    icon: Icons.fact_check_outlined,
                    titulo: 'Sin checklists',
                    mensaje: 'Crea un checklist con el boton de abajo.',
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: checklists.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final c = checklists[index];
                return FireCard(
                  onTap: () => context.push('/checklists/${c.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.nombre, style: AppTextStyles.title),
                      if (c.descripcion != null && c.descripcion!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(c.descripcion!, style: AppTextStyles.label),
                      ],
                      if (c.tipoVehiculo != null) ...[
                        const SizedBox(height: 4),
                        Text('Aplica a: ${c.tipoVehiculo}', style: AppTextStyles.label),
                      ],
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('No se pudieron cargar los checklists: $error')),
        ),
      ),
    );
  }
}
