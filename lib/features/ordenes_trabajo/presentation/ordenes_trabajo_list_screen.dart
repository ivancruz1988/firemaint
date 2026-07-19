import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/lookup_providers.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/empty_state.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../../../core/theme/widgets/status_badge.dart';
import '../../../domain/entities/enums.dart';
import '../../auth/application/auth_providers.dart';
import '../application/exportar_ordenes.dart';
import '../application/ordenes_trabajo_providers.dart';
import 'widgets/ordenes_filtros_bar.dart';

class OrdenesTrabajoListScreen extends ConsumerWidget {
  const OrdenesTrabajoListScreen({super.key});

  Future<void> _exportar(BuildContext context, WidgetRef ref, _Formato formato) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Se leen desde .future y no desde .value: si los mapas de vehiculos o
      // usuarios todavia no cargaron, el archivo saldria con celdas vacias.
      final ordenes = await ref.read(ordenesTrabajoFiltradasProvider.future);
      final vehiculos = await ref.read(vehiculosMapProvider.future);
      final usuarios = await ref.read(usuariosMapProvider.future);

      switch (formato) {
        case _Formato.excel:
          await exportarOrdenesAExcel(ordenes: ordenes, vehiculos: vehiculos, usuarios: usuarios);
        case _Formato.pdf:
          await exportarOrdenesAPdf(ordenes: ordenes, vehiculos: vehiculos, usuarios: usuarios);
      }

      messenger.showSnackBar(SnackBar(content: Text('Se exportaron ${ordenes.length} ordenes')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('No se pudo exportar: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otAsync = ref.watch(ordenesTrabajoFiltradasProvider);
    final vehiculosMap = ref.watch(vehiculosMapProvider);
    final rol = ref.watch(currentRoleProvider);
    final puedeCrear = rol == UserRole.administrador || rol == UserRole.jefeTaller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordenes de trabajo'),
        actions: [
          // Exporta lo que la pantalla esta mostrando: para un tecnico, sus
          // ordenes; para admin y jefe de taller, todas.
          if (otAsync.value?.isNotEmpty ?? false)
            PopupMenuButton<_Formato>(
              tooltip: 'Exportar',
              icon: const Icon(Icons.download_outlined),
              onSelected: (formato) => _exportar(context, ref, formato),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: _Formato.excel,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.table_chart_outlined),
                    title: Text('Exportar a Excel'),
                  ),
                ),
                PopupMenuItem(
                  value: _Formato.pdf,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.picture_as_pdf_outlined),
                    title: Text('Exportar a PDF'),
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: puedeCrear
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/ordenes-trabajo/nueva'),
              icon: const Icon(Icons.add),
              label: const Text('Nueva OT'),
            )
          : null,
      body: Column(
        children: [
          const OrdenesFiltrosBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(ordenesTrabajoListProvider),
              child: otAsync.when(
                data: (ordenes) {
                  if (ordenes.isEmpty) {
                    // Con filtros puestos el listado vacio no significa que no
                    // haya ordenes, sino que ninguna coincide: invitar a crear
                    // una nueva seria enganoso.
                    final filtrando = ref.watch(filtroOrdenesProvider).hayAlguno;
                    return ListView(
                      children: [
                        EmptyState(
                          icon: filtrando ? Icons.search_off_outlined : Icons.assignment_outlined,
                          titulo: filtrando ? 'Sin resultados' : 'Sin ordenes de trabajo',
                          mensaje: filtrando
                              ? 'Ninguna orden coincide con los filtros aplicados.'
                              : 'Crea una nueva OT con el boton de abajo.',
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: ordenes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final ot = ordenes[index];
                      final vehiculo = vehiculosMap.value?[ot.vehiculoId];
                      return FireCard(
                        onTap: () => context.push('/ordenes-trabajo/${ot.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'OT #${ot.numeroOt}',
                                  style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const Spacer(),
                                StatusBadge.prioridadOt(ot.prioridad.toDb()),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(ot.titulo, style: AppTextStyles.body),
                            const SizedBox(height: 6),
                            if (vehiculo != null)
                              Text(
                                '${vehiculo.numeroInterno} · ${vehiculo.marca} ${vehiculo.modelo}',
                                style: AppTextStyles.label,
                              ),
                            const SizedBox(height: 8),
                            StatusBadge.estadoOt(ot.estado.toDb()),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('No se pudieron cargar las OT: $error')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _Formato { excel, pdf }
