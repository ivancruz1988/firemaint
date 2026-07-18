import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/movimiento_stock.dart';
import '../../auth/application/auth_providers.dart';
import '../application/repuestos_providers.dart';

class RepuestoDetailScreen extends ConsumerWidget {
  const RepuestoDetailScreen({super.key, required this.repuestoId});

  final String repuestoId;

  Future<void> _eliminar(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar repuesto'),
        content: const Text('Esta accion no se puede deshacer. Continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await ref.read(repuestoRepositoryProvider).delete(repuestoId);
      ref.invalidate(repuestosListProvider);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
      }
    }
  }

  Future<void> _registrarMovimiento(BuildContext context, WidgetRef ref) async {
    final resultado = await showDialog<_MovimientoData>(
      context: context,
      builder: (_) => const _MovimientoDialog(),
    );
    if (resultado == null) return;
    try {
      await ref.read(repuestoRepositoryProvider).registrarMovimiento(
            MovimientoStock(
              id: '',
              repuestoId: repuestoId,
              tipoMovimiento: resultado.tipo,
              cantidad: resultado.cantidad,
              motivo: resultado.motivo,
              fechaCreacion: DateTime.now(),
            ),
          );
      ref.invalidate(repuestoByIdProvider(repuestoId));
      ref.invalidate(movimientosProvider(repuestoId));
      ref.invalidate(repuestosListProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No se pudo registrar el movimiento: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repuestoAsync = ref.watch(repuestoByIdProvider(repuestoId));
    final movimientosAsync = ref.watch(movimientosProvider(repuestoId));
    final rol = ref.watch(currentRoleProvider);
    final puedeGestionar = rol == UserRole.administrador || rol == UserRole.jefeTaller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de repuesto'),
        actions: [
          if (puedeGestionar) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/repuestos/$repuestoId/editar'),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _eliminar(context, ref),
            ),
          ],
        ],
      ),
      floatingActionButton: puedeGestionar
          ? FloatingActionButton.extended(
              onPressed: () => _registrarMovimiento(context, ref),
              icon: const Icon(Icons.swap_vert),
              label: const Text('Movimiento'),
            )
          : null,
      body: repuestoAsync.when(
        data: (r) {
          if (r == null) return const Center(child: Text('Repuesto no encontrado.'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(r.descripcion, style: AppTextStyles.headline),
              const SizedBox(height: 16),
              FireCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fila('Codigo', r.codigo),
                    _fila('Stock actual',
                        '${formatNumber(r.stock)} ${r.unidadMedida}${r.stockBajo ? '  (BAJO)' : ''}'),
                    _fila('Stock minimo', formatNumber(r.stockMinimo)),
                    if (r.ubicacion != null && r.ubicacion!.isNotEmpty) _fila('Ubicacion', r.ubicacion!),
                    if (r.costoUnitario != null)
                      _fila('Costo unitario', '\$${formatNumber(r.costoUnitario!)}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Movimientos de stock', style: AppTextStyles.title),
              const SizedBox(height: 8),
              movimientosAsync.when(
                data: (movimientos) {
                  if (movimientos.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Sin movimientos registrados.'),
                    );
                  }
                  return Column(
                    children: [
                      for (final m in movimientos) _MovimientoTile(movimiento: m),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('No se pudo cargar el repuesto: $error')),
      ),
    );
  }

  Widget _fila(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: AppTextStyles.label)),
          const SizedBox(width: 8),
          Expanded(child: Text(valor, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

class _MovimientoTile extends StatelessWidget {
  const _MovimientoTile({required this.movimiento});

  final MovimientoStock movimiento;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (movimiento.tipoMovimiento) {
      TipoMovimientoStock.ingreso => (Icons.arrow_downward, AppColors.exito),
      TipoMovimientoStock.egreso => (Icons.arrow_upward, AppColors.critico),
      TipoMovimientoStock.ajuste => (Icons.tune, AppColors.info),
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color)),
      title: Text('${movimiento.tipoMovimiento.label} · ${formatNumber(movimiento.cantidad)}'),
      subtitle: Text(
        '${formatDateTime(movimiento.fechaCreacion)}${movimiento.motivo != null ? ' · ${movimiento.motivo}' : ''}',
      ),
    );
  }
}

class _MovimientoData {
  const _MovimientoData(this.tipo, this.cantidad, this.motivo);
  final TipoMovimientoStock tipo;
  final double cantidad;
  final String? motivo;
}

class _MovimientoDialog extends StatefulWidget {
  const _MovimientoDialog();

  @override
  State<_MovimientoDialog> createState() => _MovimientoDialogState();
}

class _MovimientoDialogState extends State<_MovimientoDialog> {
  TipoMovimientoStock _tipo = TipoMovimientoStock.ingreso;
  final _cantidadController = TextEditingController();
  final _motivoController = TextEditingController();

  @override
  void dispose() {
    _cantidadController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar movimiento'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<TipoMovimientoStock>(
            initialValue: _tipo,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: [
              for (final t in TipoMovimientoStock.values)
                DropdownMenuItem(value: t, child: Text(t.label)),
            ],
            onChanged: (v) => setState(() => _tipo = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cantidadController,
            decoration: InputDecoration(
              labelText: _tipo == TipoMovimientoStock.ajuste ? 'Nuevo stock' : 'Cantidad',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _motivoController,
            decoration: const InputDecoration(labelText: 'Motivo (opcional)'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            final cantidad = double.tryParse(_cantidadController.text.trim());
            if (cantidad == null) return;
            Navigator.pop(
              context,
              _MovimientoData(
                _tipo,
                cantidad,
                _motivoController.text.trim().isEmpty ? null : _motivoController.text.trim(),
              ),
            );
          },
          child: const Text('Registrar'),
        ),
      ],
    );
  }
}
