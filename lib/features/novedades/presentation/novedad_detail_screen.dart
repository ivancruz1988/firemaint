import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/lookup_providers.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/adjuntos_section.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/novedad.dart';
import '../../../domain/entities/padre_archivo.dart';
import '../../auth/application/auth_providers.dart';
import '../application/novedades_providers.dart';

class NovedadDetailScreen extends ConsumerWidget {
  const NovedadDetailScreen({super.key, required this.novedadId});

  final String novedadId;

  Future<void> _cambiarEstado(
    BuildContext context,
    WidgetRef ref,
    Novedad n,
    EstadoNovedad nuevo,
  ) async {
    try {
      await ref.read(novedadRepositoryProvider).upsert(n.copyWith(estado: nuevo));
      ref.invalidate(novedadByIdProvider(novedadId));
      ref.invalidate(novedadesListProvider);
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
        title: const Text('Eliminar novedad'),
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
      await ref.read(novedadRepositoryProvider).delete(novedadId);
      ref.invalidate(novedadesListProvider);
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
    final novedadAsync = ref.watch(novedadByIdProvider(novedadId));
    final vehiculosMap = ref.watch(vehiculosMapProvider);
    final rol = ref.watch(currentRoleProvider);
    final puedeGestionar = rol == UserRole.administrador || rol == UserRole.jefeTaller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de novedad'),
        actions: [
          if (puedeGestionar)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _eliminar(context, ref),
            ),
        ],
      ),
      body: novedadAsync.when(
        data: (n) {
          if (n == null) return const Center(child: Text('Novedad no encontrada.'));
          final vehiculo = vehiculosMap.value?[n.vehiculoId];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(n.titulo, style: AppTextStyles.headline),
              const SizedBox(height: 16),
              FireCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fila('Tipo', n.tipo.label),
                    _fila('Estado', n.estado.label),
                    _fila(
                      'Vehiculo',
                      vehiculo == null
                          ? '—'
                          : '${vehiculo.numeroInterno} · ${vehiculo.marca} ${vehiculo.modelo}',
                    ),
                    _fila('Ocurrencia', formatDateTime(n.fechaOcurrencia)),
                    if (n.descripcion != null && n.descripcion!.isNotEmpty)
                      _fila('Descripcion', n.descripcion!),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AdjuntosSection(padre: PadreArchivo.novedad(n.id)),
              if (puedeGestionar) ...[
                const SizedBox(height: 16),
                Text('Cambiar estado', style: AppTextStyles.title),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final estado in EstadoNovedad.values)
                      ChoiceChip(
                        label: Text(estado.label),
                        selected: n.estado == estado,
                        onSelected: (_) => _cambiarEstado(context, ref, n, estado),
                      ),
                  ],
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('No se pudo cargar la novedad: $error')),
      ),
    );
  }

  Widget _fila(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: AppTextStyles.label)),
          const SizedBox(width: 8),
          Expanded(child: Text(valor, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
