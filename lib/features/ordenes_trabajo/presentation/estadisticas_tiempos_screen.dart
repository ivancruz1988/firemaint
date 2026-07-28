import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../application/historial_providers.dart';

class EstadisticasTiemposScreen extends ConsumerWidget {
  const EstadisticasTiemposScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadisticasAsync = ref.watch(estadisticasGlobalesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas de Tiempos'),
      ),
      body: estadisticasAsync.when(
        data: (estadisticas) {
          if (estadisticas.isEmpty) {
            return const Center(
              child: Text('Sin datos disponibles'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: estadisticas.length,
            itemBuilder: (context, index) {
              final stat = estadisticas[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FireCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${stat.estadoDesde ?? 'Inicio'} → ${stat.estadoHacia}',
                          style: AppTextStyles.subtitle,
                        ),
                        const SizedBox(height: 16),
                        _buildStatRow(
                          'Cantidad de transiciones:',
                          '${stat.cantidadTransiciones}',
                        ),
                        const SizedBox(height: 8),
                        _buildStatRow(
                          'Promedio:',
                          _formatearTiempo(stat.promedioDias, stat.promedioHoras),
                        ),
                        const SizedBox(height: 8),
                        _buildStatRow(
                          'Mínimo:',
                          _formatearTiempo(null, stat.minimoHoras),
                        ),
                        const SizedBox(height: 8),
                        _buildStatRow(
                          'Máximo:',
                          _formatearTiempo(null, stat.maximoHoras),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body,
        ),
        Text(
          value,
          style: AppTextStyles.subtitle,
        ),
      ],
    );
  }

  String _formatearTiempo(double? dias, double? horas) {
    if (dias == null && horas == null) {
      return 'N/A';
    }

    final d = dias?.toInt() ?? 0;
    final h = horas?.toInt() ?? 0;
    final m = ((horas ?? 0) * 60).toInt() % 60;

    if (d > 0) {
      return '$d días, $h horas';
    } else if (h > 0) {
      return '$h horas $m min';
    } else {
      return '$m minutos';
    }
  }
}
