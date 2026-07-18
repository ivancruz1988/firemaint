import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/lookup_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/empty_state.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/enums.dart';
import '../../auth/application/auth_providers.dart';
import '../application/mantenimiento_providers.dart';

class MantenimientoListScreen extends ConsumerWidget {
  const MantenimientoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mantenimientosAsync = ref.watch(mantenimientosListProvider);
    final vehiculosMap = ref.watch(vehiculosMapProvider);
    final rol = ref.watch(currentRoleProvider);
    final puedeGestionar = rol == UserRole.administrador || rol == UserRole.jefeTaller;
    final hoy = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Mantenimiento preventivo')),
      floatingActionButton: puedeGestionar
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/mantenimiento-preventivo/nuevo'),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo plan'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(mantenimientosListProvider),
        child: mantenimientosAsync.when(
          data: (mantenimientos) {
            if (mantenimientos.isEmpty) {
              return ListView(
                children: const [
                  EmptyState(
                    icon: Icons.event_repeat_outlined,
                    titulo: 'Sin planes de mantenimiento',
                    mensaje: 'Programa un mantenimiento con el boton de abajo.',
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mantenimientos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final m = mantenimientos[index];
                final vehiculo = vehiculosMap.value?[m.vehiculoId];
                final vencido = m.proximaFecha.isBefore(hoy);
                return FireCard(
                  onTap: () => context.push('/mantenimiento-preventivo/${m.id}/editar'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(m.nombre, style: AppTextStyles.title)),
                          Text(m.frecuencia.label, style: AppTextStyles.label),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (vehiculo != null)
                        Text('${vehiculo.numeroInterno} · ${vehiculo.marca} ${vehiculo.modelo}',
                            style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.event,
                              size: 16, color: vencido ? AppColors.critico : AppColors.info),
                          const SizedBox(width: 4),
                          Text(
                            'Proxima: ${formatDate(m.proximaFecha)}${vencido ? '  (VENCIDO)' : ''}',
                            style: TextStyle(
                              color: vencido ? AppColors.critico : AppColors.grisOscuro,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('No se pudieron cargar los planes: $error')),
        ),
      ),
    );
  }
}
