import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ordenes_trabajo/application/ordenes_trabajo_providers.dart';
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

  /// Envuelve el icono en un globo con la cantidad de OT abiertas asignadas al
  /// usuario. Se muestra solo en la pestana de Ordenes y solo si hay alguna.
  Widget _iconoConGlobo(_Tab tab, int pendientes) {
    if (tab.label != 'Ordenes' || pendientes == 0) return Icon(tab.icon);
    return Badge.count(
      count: pendientes,
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
    // Si la consulta falla o esta cargando se muestra el menu sin globo, que
    // es preferible a bloquear la navegacion por un contador.
    final pendientes = ref.watch(misOrdenesPendientesProvider).value?.length ?? 0;

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
                      child:
                          Icon(Icons.local_fire_department, color: AppColors.rojoBombero, size: 32),
                    ),
                    destinations: [
                      for (final tab in _tabs)
                        NavigationRailDestination(
                          icon: _iconoConGlobo(tab, pendientes),
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
            NavigationDestination(icon: _iconoConGlobo(tab, pendientes), label: tab.label),
        ],
      ),
    );
  }
}
