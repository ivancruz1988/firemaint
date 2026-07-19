import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/lookup_providers.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../../../core/theme/widgets/status_badge.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/orden_trabajo.dart';
import '../../auth/application/auth_providers.dart';
import '../application/ordenes_trabajo_providers.dart';

class OrdenTrabajoDetailScreen extends ConsumerWidget {
  const OrdenTrabajoDetailScreen({super.key, required this.ordenId});

  final String ordenId;

  Future<void> _cambiarEstado(
    BuildContext context,
    WidgetRef ref,
    OrdenTrabajo ot,
    EstadoOt nuevo,
  ) async {
    try {
      await ref.read(ordenTrabajoRepositoryProvider).upsert(ot.copyWith(estado: nuevo));
      ref.invalidate(ordenTrabajoByIdProvider(ordenId));
      ref.invalidate(ordenesTrabajoListProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo cambiar el estado: $e')));
      }
    }
  }

  Future<void> _eliminar(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar orden de trabajo'),
        content: const Text('Esta accion no se puede deshacer. Continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await ref.read(ordenTrabajoRepositoryProvider).delete(ordenId);
      ref.invalidate(ordenesTrabajoListProvider);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otAsync = ref.watch(ordenTrabajoByIdProvider(ordenId));
    final vehiculosMap = ref.watch(vehiculosMapProvider);
    final usuariosMap = ref.watch(usuariosMapProvider);
    final rol = ref.watch(currentRoleProvider);
    final puedeEditar = rol == UserRole.administrador || rol == UserRole.jefeTaller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de OT'),
        actions: [
          if (puedeEditar) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/ordenes-trabajo/$ordenId/editar'),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _eliminar(context, ref),
            ),
          ],
        ],
      ),
      body: otAsync.when(
        data: (ot) {
          if (ot == null) return const Center(child: Text('OT no encontrada.'));
          final vehiculo = vehiculosMap.value?[ot.vehiculoId];
          final tecnico = ot.tecnicoAsignadoId == null
              ? null
              : usuariosMap.value?[ot.tecnicoAsignadoId];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Text('OT #${ot.numeroOt}', style: AppTextStyles.headline),
                  const Spacer(),
                  StatusBadge.prioridadOt(ot.prioridad.toDb()),
                ],
              ),
              const SizedBox(height: 8),
              Text(ot.titulo, style: AppTextStyles.title),
              const SizedBox(height: 16),
              FireCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fila('Estado', null, badge: StatusBadge.estadoOt(ot.estado.toDb())),
                    const Divider(),
                    _fila(
                      'Vehiculo',
                      vehiculo == null
                          ? '—'
                          : '${vehiculo.numeroInterno} · ${vehiculo.marca} ${vehiculo.modelo}',
                    ),
                    _fila('Tecnico asignado', tecnico?.nombreCompleto ?? 'Sin asignar'),
                    _fila('Prioridad', ot.prioridad.label),
                    if (ot.descripcion != null && ot.descripcion!.isNotEmpty)
                      _fila('Descripcion', ot.descripcion!),
                    if (ot.horasTrabajo != null)
                      _fila('Horas de trabajo', ot.horasTrabajo.toString()),
                    if (ot.costoEstimado != null)
                      _fila('Costo estimado', '\$${formatNumber(ot.costoEstimado!)}'),
                    if (ot.costoReal != null)
                      _fila('Costo real', '\$${formatNumber(ot.costoReal!)}'),
                    if (ot.fechaInicio != null) _fila('Inicio', formatDateTime(ot.fechaInicio!)),
                    if (ot.fechaFin != null) _fila('Fin', formatDateTime(ot.fechaFin!)),
                    if (ot.observaciones != null && ot.observaciones!.isNotEmpty)
                      _fila('Observaciones', ot.observaciones!),
                    _fila('Creada', formatDateTime(ot.fechaCreacion)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Cambiar estado', style: AppTextStyles.title),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final estado in EstadoOt.values)
                    ChoiceChip(
                      label: Text(estado.label),
                      selected: ot.estado == estado,
                      onSelected: (_) => _cambiarEstado(context, ref, ot, estado),
                    ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('No se pudo cargar la OT: $error')),
      ),
    );
  }

  Widget _fila(String label, String? valor, {Widget? badge}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: AppTextStyles.label)),
          const SizedBox(width: 8),
          Expanded(child: badge ?? Text(valor ?? '—', style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
