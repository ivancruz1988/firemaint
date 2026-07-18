import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/lookup_providers.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/empty_state.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../../../core/theme/widgets/status_badge.dart';
import '../../../domain/entities/enums.dart';
import '../../auth/application/auth_providers.dart';
import '../application/ordenes_trabajo_providers.dart';

class OrdenesTrabajoListScreen extends ConsumerWidget {
  const OrdenesTrabajoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otAsync = ref.watch(ordenesTrabajoListProvider);
    final vehiculosMap = ref.watch(vehiculosMapProvider);
    final rol = ref.watch(currentRoleProvider);
    final puedeCrear = rol == UserRole.administrador || rol == UserRole.jefeTaller;

    return Scaffold(
      appBar: AppBar(title: const Text('Ordenes de trabajo')),
      floatingActionButton: puedeCrear
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/ordenes-trabajo/nueva'),
              icon: const Icon(Icons.add),
              label: const Text('Nueva OT'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(ordenesTrabajoListProvider),
        child: otAsync.when(
          data: (ordenes) {
            if (ordenes.isEmpty) {
              return ListView(
                children: const [
                  EmptyState(
                    icon: Icons.assignment_outlined,
                    titulo: 'Sin ordenes de trabajo',
                    mensaje: 'Crea una nueva OT con el boton de abajo.',
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ordenes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final ot = ordenes[index];
                final vehiculo = vehiculosMap.value?[ot.vehiculoId];
                return FireCard(
                  onTap: () => context.push('/ordenes-trabajo/${ot.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('OT #${ot.numeroOt}',
                              style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w800)),
                          const Spacer(),
                          StatusBadge.prioridadOt(ot.prioridad.toDb()),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(ot.titulo, style: AppTextStyles.body),
                      const SizedBox(height: 6),
                      if (vehiculo != null)
                        Text(
                          '${vehiculo.numeroInterno} · ${vehiculo.marca} ${vehiculo.modelo}',
                          style: AppTextStyles.label,
                        ),
                      const SizedBox(height: 8),
                      StatusBadge.estadoOt(ot.estado.toDb()),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('No se pudieron cargar las OT: $error')),
        ),
      ),
    );
  }
}
