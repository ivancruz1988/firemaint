import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/enums.dart';
import '../../features/auth/application/auth_providers.dart';
import '../../features/mantenimiento_preventivo/application/mantenimiento_providers.dart';
import '../../features/ordenes_trabajo/application/ordenes_trabajo_providers.dart';
import '../../features/repuestos/application/repuestos_providers.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../widgets/banner_sin_conexion.dart';

class _Tab {
  const _Tab(this.label, this.icon);
  final String label;
  final IconData icon;
}

const _tabs = [
  _Tab('Dashboard', Icons.dashboard_outlined),
  _Tab('Vehiculos', Icons.local_shipping_outlined),
  _Tab('Ordenes', Icons.assignment_outlined),
  _Tab('Checklists', Icons.fact_check_outlined),
  _Tab('Preventivo', Icons.event_repeat_outlined),
  _Tab('Novedades', Icons.report_problem_outlined),
  _Tab('Repuestos', Icons.settings_suggest_outlined),
  _Tab('Reportes', Icons.bar_chart_outlined),
  _Tab('Configuracion', Icons.settings_outlined),
];

/// Shell responsive: NavigationRail en pantallas anchas (desktop/PWA),
/// NavigationBar inferior en celular.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Envuelve el icono en un globo con la cantidad que corresponda segun la
  /// pestana (OT asignadas en Ordenes, planes vencidos en Preventivo). Sin
  /// contador para esa pestana, o en cero, se muestra el icono solo.
  Widget _iconoConGlobo(_Tab tab, Map<String, int> contadores) {
    final cantidad = contadores[tab.label] ?? 0;
    if (cantidad == 0) return Icon(tab.icon);
    return Badge.count(
      count: cantidad,
      backgroundColor: AppColors.critico,
      textColor: AppColors.blanco,
      child: Icon(tab.icon),
    );
  }

  void _onSelect(int index) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Si alguna consulta falla o esta cargando se muestra el menu sin globo
    // para esa pestana, que es preferible a bloquear la navegacion.
    final rol = ref.watch(currentRoleProvider);
    final puedeGestionarPreventivo = rol == UserRole.administrador || rol == UserRole.jefeTaller;
    final contadores = {
      'Ordenes': ref.watch(misOrdenesPendientesProvider).value?.length ?? 0,
      if (puedeGestionarPreventivo) ...{
        'Preventivo': ref.watch(mantenimientosVencidosProvider).value?.length ?? 0,
        'Repuestos': ref.watch(repuestosStockBajoProvider).value?.length ?? 0,
      },
    };

    if (context.isDesktop) {
      return Scaffold(
        body: Column(
          children: [
            const BannerSinConexion(),
            Expanded(
              child: Row(
                children: [
                  NavigationRail(
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: _onSelect,
                    labelType: NavigationRailLabelType.all,
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Icon(
                        Icons.local_fire_department,
                        color: AppColors.rojoBombero,
                        size: 32,
                      ),
                    ),
                    destinations: [
                      for (final tab in _tabs)
                        NavigationRailDestination(
                          icon: _iconoConGlobo(tab, contadores),
                          label: Text(tab.label),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: navigationShell),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          const BannerSinConexion(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onSelect,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(icon: _iconoConGlobo(tab, contadores), label: tab.label),
        ],
      ),
    );
  }
}
