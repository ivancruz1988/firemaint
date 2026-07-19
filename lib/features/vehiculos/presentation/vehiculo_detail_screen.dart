import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../../../core/theme/widgets/status_badge.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/vehiculo.dart';
import '../../auth/application/auth_providers.dart';
import '../../dashboard/application/dashboard_providers.dart';
import '../application/vehiculos_providers.dart';
import 'widgets/adjuntos_section.dart';

class VehiculoDetailScreen extends ConsumerWidget {
  const VehiculoDetailScreen({super.key, required this.vehiculoId});

  final String vehiculoId;

  Future<void> _eliminar(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar vehiculo'),
        content: const Text('Esta accion no se puede deshacer. Confirmas la eliminacion?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar != true) return;
    await ref.read(vehiculoRepositoryProvider).delete(vehiculoId);
    ref.invalidate(vehiculosListProvider);
    ref.invalidate(dashboardKpisProvider);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiculoAsync = ref.watch(vehiculoByIdProvider(vehiculoId));
    final rol = ref.watch(currentRoleProvider);
    final puedeEditar = rol == UserRole.administrador || rol == UserRole.jefeTaller;
    final puedeEliminar = rol == UserRole.administrador;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha del vehiculo'),
        actions: [
          if (puedeEditar)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/vehiculos/$vehiculoId/editar'),
            ),
          if (puedeEliminar)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _eliminar(context, ref),
            ),
        ],
      ),
      body: vehiculoAsync.when(
        data: (vehiculo) {
          if (vehiculo == null) {
            return const Center(child: Text('El vehiculo no existe o fue eliminado.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SeccionIdentificacion(vehiculo: vehiculo),
              const SizedBox(height: 12),
              _SeccionUso(vehiculo: vehiculo),
              const SizedBox(height: 12),
              AdjuntosSection(vehiculoId: vehiculo.id),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('No se pudo cargar el vehiculo: $error')),
      ),
    );
  }
}

class _SeccionIdentificacion extends StatelessWidget {
  const _SeccionIdentificacion({required this.vehiculo});

  final Vehiculo vehiculo;

  @override
  Widget build(BuildContext context) {
    return FireCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${vehiculo.numeroInterno} — ${vehiculo.marca} ${vehiculo.modelo}',
                    style: AppTextStyles.headline),
              ),
              StatusBadge.estadoOperativo(vehiculo.estadoOperativo.toDb()),
            ],
          ),
          const SizedBox(height: 12),
          _Fila('Dominio', vehiculo.dominio ?? '-'),
          _Fila('Tipo', vehiculo.tipo.label),
          _Fila('Anio', vehiculo.anio?.toString() ?? '-'),
          _Fila('Fecha de alta', formatDate(vehiculo.fechaAlta)),
          if (vehiculo.observaciones != null && vehiculo.observaciones!.isNotEmpty)
            _Fila('Observaciones', vehiculo.observaciones!),
        ],
      ),
    );
  }
}

class _SeccionUso extends StatelessWidget {
  const _SeccionUso({required this.vehiculo});

  final Vehiculo vehiculo;

  @override
  Widget build(BuildContext context) {
    return FireCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Uso', style: AppTextStyles.title),
          const SizedBox(height: 8),
          _Fila('Kilometraje', '${formatNumber(vehiculo.kilometraje)} km'),
          _Fila('Horas de bomba', formatNumber(vehiculo.horasBomba)),
          _Fila('Ultima actualizacion', formatDateTime(vehiculo.fechaModificacion)),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(etiqueta, style: AppTextStyles.label)),
          Expanded(child: Text(valor, style: AppTextStyles.body.copyWith(color: AppColors.textoPrincipal))),
        ],
      ),
    );
  }
}
