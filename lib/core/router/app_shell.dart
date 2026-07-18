import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../utils/responsive.dart';

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
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onSelect(int index) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onSelect,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Icon(Icons.local_fire_department, color: AppColors.rojoBombero, size: 32),
              ),
              destinations: [
                for (final tab in _tabs)
                  NavigationRailDestination(icon: Icon(tab.icon), label: Text(tab.label)),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onSelect,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          for (final tab in _tabs) NavigationDestination(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
    );
  }
}
