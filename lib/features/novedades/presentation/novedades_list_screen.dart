import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/lookup_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/empty_state.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../../../core/theme/widgets/status_badge.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/enums.dart';
import '../application/novedades_providers.dart';

class NovedadesListScreen extends ConsumerWidget {
  const NovedadesListScreen({super.key});

  Color _colorEstado(EstadoNovedad estado) => switch (estado) {
        EstadoNovedad.abierta => AppColors.critico,
        EstadoNovedad.enAtencion => AppColors.alerta,
        EstadoNovedad.resuelta => AppColors.exito,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final novedadesAsync = ref.watch(novedadesListProvider);
    final vehiculosMap = ref.watch(vehiculosMapProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Novedades')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/novedades/nueva'),
        icon: const Icon(Icons.add),
        label: const Text('Reportar novedad'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(novedadesListProvider),
        child: novedadesAsync.when(
          data: (novedades) {
            if (novedades.isEmpty) {
              return ListView(
                children: const [
                  EmptyState(
                    icon: Icons.report_problem_outlined,
                    titulo: 'Sin novedades',
                    mensaje: 'Reporta una averia o falla con el boton de abajo.',
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: novedades.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final n = novedades[index];
                final vehiculo = vehiculosMap.value?[n.vehiculoId];
                return FireCard(
                  onTap: () => context.push('/novedades/${n.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(n.titulo, style: AppTextStyles.title)),
                          StatusBadge(label: n.estado.label, color: _colorEstado(n.estado)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(n.tipo.label, style: AppTextStyles.label),
                      if (vehiculo != null)
                        Text(
                          '${vehiculo.numeroInterno} · ${vehiculo.marca} ${vehiculo.modelo}',
                          style: AppTextStyles.label,
                        ),
                      const SizedBox(height: 4),
                      Text(formatDateTime(n.fechaOcurrencia), style: AppTextStyles.label),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('No se pudieron cargar las novedades: $error')),
        ),
      ),
    );
  }
}
