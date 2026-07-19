import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/application/auth_providers.dart';
import '../../ordenes_trabajo/application/ordenes_trabajo_providers.dart';
import '../application/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpisAsync = ref.watch(dashboardKpisProvider);
    final usuarioAsync = ref.watch(currentUsuarioProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Stack(
        children: [
          const _MarcaDeAgua(),
          RefreshIndicator(
            onRefresh: () async => ref.invalidate(dashboardKpisProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  usuarioAsync.value != null
                      ? 'Hola, ${usuarioAsync.value!.nombreCompleto}'
                      : 'Hola',
                  style: AppTextStyles.headline,
                ),
                const SizedBox(height: 4),
                const Text('Estado general de la flota', style: AppTextStyles.label),
                const SizedBox(height: 20),
                const _AvisoTareasPendientes(),
                kpisAsync.when(
                  data: (kpis) => LayoutBuilder(
                    builder: (context, constraints) {
                      final columnas = context.isDesktop ? 4 : 2;
                      return GridView.count(
                        crossAxisCount: columnas,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: [
                          _KpiTile(
                            icono: Icons.local_shipping_outlined,
                            etiqueta: 'Vehiculos operativos',
                            valor: kpis.operativos,
                            color: AppColors.exito,
                          ),
                          _KpiTile(
                            icono: Icons.report_gmailerrorred_outlined,
                            etiqueta: 'Fuera de servicio',
                            valor: kpis.fueraDeServicio,
                            color: AppColors.critico,
                          ),
                        ],
                      );
                    },
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('No se pudieron cargar los indicadores: $error'),
                  ),
                ),
                const SizedBox(height: 16),
                FireCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bar_chart_outlined,
                            color: AppColors.textoPrincipal.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 8),
                          Text('Reportes y graficos', style: AppTextStyles.title),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Costos por unidad, fallas por vehiculo, cumplimiento preventivo. '
                        'Proximamente en el modulo de Reportes.',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.color,
  });

  final IconData icono;
  final String etiqueta;
  final int valor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FireCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color),
          const Spacer(),
          Text('$valor', style: AppTextStyles.kpiNumber.copyWith(color: color)),
          Text(etiqueta, style: AppTextStyles.label, maxLines: 2),
        ],
      ),
    );
  }
}

/// Logo institucional como marca de agua detras del contenido del Dashboard.
///
/// El archivo original es verde y dorado, pensado para fondo claro: sobre el
/// tema oscuro no se distinguiria. Se lo tine de un tono claro y se lo baja a
/// una opacidad muy baja para que aporte identidad sin competir con los KPIs.
class _MarcaDeAgua extends StatelessWidget {
  const _MarcaDeAgua();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: Opacity(
              opacity: 0.06,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(AppColors.textoPrincipal, BlendMode.srcIn),
                child: Image.asset('assets/images/logo_cuartel.png'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Aviso de ordenes de trabajo abiertas asignadas al usuario que esta viendo
/// el Dashboard. No se muestra nada si no tiene ninguna, para no ocupar
/// espacio con un cartel vacio.
class _AvisoTareasPendientes extends ConsumerWidget {
  const _AvisoTareasPendientes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendientes = ref.watch(misOrdenesPendientesProvider).value ?? const [];
    if (pendientes.isEmpty) return const SizedBox.shrink();

    final cantidad = pendientes.length;
    final esUna = cantidad == 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: AppColors.alerta.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.go('/ordenes-trabajo'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.assignment_late_outlined, color: AppColors.alerta),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        esUna ? 'Tenes 1 tarea pendiente' : 'Tenes $cantidad tareas pendientes',
                        style: AppTextStyles.title,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        esUna
                            ? pendientes.first.titulo
                            : 'Toca para ver las ordenes asignadas a vos',
                        style: AppTextStyles.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.alerta),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
