import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/fire_card.dart';
import '../../../../core/utils/formatters.dart';
import '../../application/historial_providers.dart';

class HistorialCambiosWidget extends ConsumerWidget {
  const HistorialCambiosWidget({super.key, required this.ordenId});

  final String ordenId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historialAsync = ref.watch(historialOrdenTrabajoProvider(ordenId));
    final estadisticasAsync = ref.watch(estadisticasOrdenTrabajoProvider(ordenId));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estadísticas de tiempo
            estadisticasAsync.when(
              data: (stats) => FireCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estadísticas de Tiempo',
                        style: AppTextStyles.headline6,
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow(
                        'Tiempo promedio:',
                        _formatearTiempo(stats),
                      ),
                      if (stats.cantidadTransiciones > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildStatRow(
                            'Transiciones registradas:',
                            '${stats.cantidadTransiciones}',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
            ),
            const SizedBox(height: 24),
            // Historial de cambios
            Text('Historial de Cambios', style: AppTextStyles.headline6),
            const SizedBox(height: 12),
            historialAsync.when(
              data: (historial) {
                if (historial.isEmpty) {
                  return FireCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Sin cambios registrados',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: historial.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final cambio = historial[index];
                    return FireCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${cambio.estadoAnterior ?? 'Inicio'} → ${cambio.estadoNuevo}',
                                        style: AppTextStyles.bodySemibold,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        Formatters.formatearFecha(cambio.fechaCambio),
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (cambio.usuarioNombre != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Por: ${cambio.usuarioNombre}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ),
                            if (cambio.observacion != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  cambio.observacion!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: AppTextStyles.bodySemibold,
        ),
      ],
    );
  }

  String _formatearTiempo(EstadisticasTiempos stats) {
    if (stats.promedioDias == null && stats.promedioHoras == null) {
      return 'N/A';
    }

    final dias = stats.promedioDias?.toInt() ?? 0;
    final horas = stats.promedioHoras?.toInt() ?? 0;
    final minutos = ((stats.promedioHoras ?? 0) * 60).toInt() % 60;

    if (dias > 0) {
      return '$dias días, $horas horas';
    } else if (horas > 0) {
      return '$horas horas $minutos min';
    } else {
      return '$minutos minutos';
    }
  }
}
