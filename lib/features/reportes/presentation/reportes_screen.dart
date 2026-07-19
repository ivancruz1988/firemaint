import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../../../domain/entities/enums.dart';
import '../application/reportes_providers.dart';

class ReportesScreen extends ConsumerWidget {
  const ReportesScreen({super.key});

  Color _colorEstadoOt(EstadoOt estado) => switch (estado) {
    EstadoOt.pendiente => AppColors.alerta,
    EstadoOt.enProceso => AppColors.info,
    EstadoOt.esperandoRepuestos => AppColors.amarilloSeguridad,
    EstadoOt.finalizada => AppColors.exito,
    EstadoOt.cancelada => AppColors.textoTenue,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reporteAsync = ref.watch(reporteDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(reporteDataProvider),
        child: reporteAsync.when(
          data: (data) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Resumen general', style: AppTextStyles.title),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _StatCard(
                    titulo: 'Vehiculos operativos',
                    valor: '${data.vehiculosOperativos}',
                    color: AppColors.exito,
                    icon: Icons.check_circle_outline,
                  ),
                  _StatCard(
                    titulo: 'Fuera de servicio',
                    valor: '${data.vehiculosFueraDeServicio}',
                    color: AppColors.critico,
                    icon: Icons.dangerous_outlined,
                  ),
                  _StatCard(
                    titulo: 'Novedades abiertas',
                    valor: '${data.novedadesAbiertas}',
                    color: AppColors.alerta,
                    icon: Icons.report_problem_outlined,
                  ),
                  _StatCard(
                    titulo: 'Repuestos stock bajo',
                    valor: '${data.repuestosStockBajo}',
                    color: AppColors.rojoBombero,
                    icon: Icons.inventory_2_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Ordenes de trabajo por estado', style: AppTextStyles.title),
              const SizedBox(height: 12),
              FireCard(
                child: data.totalOt == 0
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('No hay ordenes de trabajo todavia.')),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: [
                                  for (final estado in EstadoOt.values)
                                    if ((data.otPorEstado[estado] ?? 0) > 0)
                                      PieChartSectionData(
                                        value: (data.otPorEstado[estado] ?? 0).toDouble(),
                                        color: _colorEstadoOt(estado),
                                        title: '${data.otPorEstado[estado]}',
                                        radius: 60,
                                        titleStyle: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              for (final estado in EstadoOt.values)
                                if ((data.otPorEstado[estado] ?? 0) > 0)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 14,
                                        height: 14,
                                        color: _colorEstadoOt(estado),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${estado.label} (${data.otPorEstado[estado]})',
                                        style: AppTextStyles.label,
                                      ),
                                    ],
                                  ),
                            ],
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
              Text('Flota por estado', style: AppTextStyles.title),
              const SizedBox(height: 12),
              FireCard(
                child: Column(
                  children: [
                    _BarraEstado(
                      label: 'Operativos',
                      cantidad: data.vehiculosOperativos,
                      total: data.totalVehiculos,
                      color: AppColors.exito,
                    ),
                    _BarraEstado(
                      label: 'En mantenimiento',
                      cantidad: data.vehiculosEnMantenimiento,
                      total: data.totalVehiculos,
                      color: AppColors.alerta,
                    ),
                    _BarraEstado(
                      label: 'Fuera de servicio',
                      cantidad: data.vehiculosFueraDeServicio,
                      total: data.totalVehiculos,
                      color: AppColors.critico,
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('No se pudieron cargar los reportes: $error')),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.titulo,
    required this.valor,
    required this.color,
    required this.icon,
  });

  final String titulo;
  final String valor;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FireCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const Spacer(),
          Text(valor, style: AppTextStyles.kpiNumber.copyWith(color: color)),
          Text(titulo, style: AppTextStyles.label, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _BarraEstado extends StatelessWidget {
  const _BarraEstado({
    required this.label,
    required this.cantidad,
    required this.total,
    required this.color,
  });

  final String label;
  final int cantidad;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraccion = total == 0 ? 0.0 : cantidad / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: AppTextStyles.body)),
              Text('$cantidad', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraccion,
              minHeight: 10,
              backgroundColor: Colors.black12,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
