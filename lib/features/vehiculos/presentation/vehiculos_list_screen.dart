import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/widgets/empty_state.dart';
import '../../../domain/entities/enums.dart';
import '../../auth/application/auth_providers.dart';
import '../application/vehiculos_providers.dart';
import 'widgets/vehiculo_card.dart';
import 'widgets/vehiculo_filtros_bar.dart';

class VehiculosListScreen extends ConsumerWidget {
  const VehiculosListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiculosAsync = ref.watch(vehiculosListProvider);
    final rol = ref.watch(currentRoleProvider);
    final puedeCrear = rol == UserRole.administrador || rol == UserRole.jefeTaller;

    return Scaffold(
      appBar: AppBar(title: const Text('Vehiculos')),
      floatingActionButton: puedeCrear
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/vehiculos/nuevo'),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo vehiculo'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(vehiculosListProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const VehiculoFiltrosBar(),
            const SizedBox(height: 16),
            vehiculosAsync.when(
              data: (vehiculos) {
                if (vehiculos.isEmpty) {
                  return const EmptyState(
                    icon: Icons.local_shipping_outlined,
                    titulo: 'Sin vehiculos',
                    mensaje: 'No se encontraron unidades con los filtros actuales.',
                  );
                }
                return Column(
                  children: [
                    for (final vehiculo in vehiculos) ...[
                      VehiculoCard(
                        vehiculo: vehiculo,
                        onTap: () => context.push('/vehiculos/${vehiculo.id}'),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text('No se pudieron cargar los vehiculos: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
