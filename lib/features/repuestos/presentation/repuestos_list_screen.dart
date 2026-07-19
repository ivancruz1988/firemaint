import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/empty_state.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/enums.dart';
import '../../auth/application/auth_providers.dart';
import '../application/repuestos_providers.dart';

class RepuestosListScreen extends ConsumerWidget {
  const RepuestosListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repuestosAsync = ref.watch(repuestosListProvider);
    final rol = ref.watch(currentRoleProvider);
    final puedeGestionar = rol == UserRole.administrador || rol == UserRole.jefeTaller;

    return Scaffold(
      appBar: AppBar(title: const Text('Repuestos')),
      floatingActionButton: puedeGestionar
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/repuestos/nuevo'),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo repuesto'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(repuestosListProvider),
        child: repuestosAsync.when(
          data: (repuestos) {
            if (repuestos.isEmpty) {
              return ListView(
                children: const [
                  EmptyState(
                    icon: Icons.inventory_2_outlined,
                    titulo: 'Sin repuestos',
                    mensaje: 'Carga tu primer repuesto con el boton de abajo.',
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: repuestos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final r = repuestos[index];
                return FireCard(
                  onTap: () => context.push('/repuestos/${r.id}'),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.descripcion, style: AppTextStyles.title),
                            const SizedBox(height: 4),
                            Text('Codigo: ${r.codigo}', style: AppTextStyles.label),
                            if (r.ubicacion != null && r.ubicacion!.isNotEmpty)
                              Text('Ubicacion: ${r.ubicacion}', style: AppTextStyles.label),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${formatNumber(r.stock)} ${r.unidadMedida}',
                            style: AppTextStyles.title.copyWith(
                              color: r.stockBajo ? AppColors.critico : AppColors.textoPrincipal,
                            ),
                          ),
                          if (r.stockBajo)
                            const Text('Stock bajo',
                                style: TextStyle(color: AppColors.critico, fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('No se pudieron cargar los repuestos: $error')),
        ),
      ),
    );
  }
}
