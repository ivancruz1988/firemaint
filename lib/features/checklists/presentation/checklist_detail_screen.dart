import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/empty_state.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../../../domain/entities/checklist_item.dart';
import '../../../domain/entities/enums.dart';
import '../../auth/application/auth_providers.dart';
import '../application/checklists_providers.dart';
import '../data/plantilla_bomberil.dart';

class ChecklistDetailScreen extends ConsumerWidget {
  const ChecklistDetailScreen({super.key, required this.checklistId});

  final String checklistId;

  Future<void> _cargarPlantilla(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cargar plantilla bomberil'),
        content: const Text(
            'Se agregaran las 13 secciones con todos los items del checklist de camion de bomberos. Continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Cargar')),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await ref
          .read(checklistRepositoryProvider)
          .insertItems(construirItemsBomberil(checklistId));
      ref.invalidate(checklistItemsProvider(checklistId));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No se pudo cargar la plantilla: $e')));
      }
    }
  }

  Future<void> _reiniciarResultados(
      BuildContext context, WidgetRef ref, List<ChecklistItem> items) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reiniciar resultados'),
        content: const Text('Se borraran los OK/NO OK y observaciones de todos los items. Continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Reiniciar')),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      final repo = ref.read(checklistRepositoryProvider);
      await Future.wait(
        items.where((i) => i.resultado != null || i.observacion != null).map(
              (i) => repo.upsertItem(i.copyWith(limpiarResultado: true)),
            ),
      );
      ref.invalidate(checklistItemsProvider(checklistId));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No se pudieron reiniciar: $e')));
      }
    }
  }

  Future<void> _marcar(WidgetRef ref, ChecklistItem item, ResultadoChecklistItem resultado) async {
    // Tocar el resultado ya seleccionado lo deselecciona (vuelve a pendiente).
    final nuevoResultado = item.resultado == resultado ? null : resultado;
    final actualizado = ChecklistItem(
      id: item.id,
      checklistId: item.checklistId,
      ordenTrabajoId: item.ordenTrabajoId,
      categoria: item.categoria,
      descripcion: item.descripcion,
      orden: item.orden,
      resultado: nuevoResultado,
      observacion: item.observacion,
    );
    await ref.read(checklistRepositoryProvider).upsertItem(actualizado);
    ref.invalidate(checklistItemsProvider(checklistId));
  }

  Future<void> _editarObservacion(BuildContext context, WidgetRef ref, ChecklistItem item) async {
    final texto = await showDialog<String>(
      context: context,
      builder: (_) => _TextoDialog(titulo: 'Observacion', inicial: item.observacion),
    );
    if (texto == null) return;
    await ref.read(checklistRepositoryProvider).upsertItem(
          ChecklistItem(
            id: item.id,
            checklistId: item.checklistId,
            ordenTrabajoId: item.ordenTrabajoId,
            categoria: item.categoria,
            descripcion: item.descripcion,
            orden: item.orden,
            resultado: item.resultado,
            observacion: texto.trim().isEmpty ? null : texto.trim(),
          ),
        );
    ref.invalidate(checklistItemsProvider(checklistId));
  }

  Future<void> _agregarItem(BuildContext context, WidgetRef ref, int orden) async {
    final texto = await showDialog<String>(
      context: context,
      builder: (_) => const _TextoDialog(titulo: 'Nuevo item'),
    );
    if (texto == null || texto.trim().isEmpty) return;
    await ref.read(checklistRepositoryProvider).upsertItem(
          ChecklistItem(id: '', checklistId: checklistId, descripcion: texto.trim(), orden: orden),
        );
    ref.invalidate(checklistItemsProvider(checklistId));
  }

  Future<void> _eliminarItem(WidgetRef ref, String itemId) async {
    await ref.read(checklistRepositoryProvider).deleteItem(itemId);
    ref.invalidate(checklistItemsProvider(checklistId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checklistAsync = ref.watch(checklistByIdProvider(checklistId));
    final itemsAsync = ref.watch(checklistItemsProvider(checklistId));
    final rol = ref.watch(currentRoleProvider);
    final puedeGestionar = rol == UserRole.administrador || rol == UserRole.jefeTaller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist'),
        actions: [
          if (puedeGestionar) ...[
            IconButton(
              tooltip: 'Reiniciar resultados',
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final items = itemsAsync.value;
                if (items != null) _reiniciarResultados(context, ref, items);
              },
            ),
            IconButton(
              tooltip: 'Editar datos',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/checklists/$checklistId/editar'),
            ),
          ],
        ],
      ),
      floatingActionButton: puedeGestionar
          ? FloatingActionButton.extended(
              onPressed: () => _agregarItem(context, ref, itemsAsync.value?.length ?? 0),
              icon: const Icon(Icons.add),
              label: const Text('Agregar item'),
            )
          : null,
      body: checklistAsync.when(
        data: (checklist) {
          if (checklist == null) return const Center(child: Text('Checklist no encontrado.'));
          return itemsAsync.when(
            data: (items) => _buildContenido(context, ref, checklist.nombre,
                checklist.descripcion, items, puedeGestionar),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error cargando items: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('No se pudo cargar el checklist: $error')),
      ),
    );
  }

  Widget _buildContenido(BuildContext context, WidgetRef ref, String nombre, String? descripcion,
      List<ChecklistItem> items, bool puedeGestionar) {
    if (items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 24),
          EmptyState(
            icon: Icons.fact_check_outlined,
            titulo: nombre,
            mensaje: 'Este checklist todavia no tiene items.',
          ),
          if (puedeGestionar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: FilledButton.icon(
                onPressed: () => _cargarPlantilla(context, ref),
                icon: const Icon(Icons.local_fire_department),
                label: const Text('Cargar plantilla de camion de bomberos'),
              ),
            ),
        ],
      );
    }

    // Agrupar por categoria conservando el orden.
    final grupos = <String, List<ChecklistItem>>{};
    for (final item in items) {
      grupos.putIfAbsent(item.categoria ?? 'Otros', () => []).add(item);
    }

    final ok = items.where((i) => i.resultado == ResultadoChecklistItem.cumple).length;
    final noOk = items.where((i) => i.resultado == ResultadoChecklistItem.noCumple).length;
    final pendientes = items.where((i) => i.resultado == null).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(nombre, style: AppTextStyles.headline),
        if (descripcion != null && descripcion.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(descripcion, style: AppTextStyles.label),
        ],
        const SizedBox(height: 16),
        _ResumenBar(ok: ok, noOk: noOk, pendientes: pendientes, total: items.length),
        const SizedBox(height: 16),
        for (final entry in grupos.entries) ...[
          _SeccionHeader(titulo: entry.key),
          const SizedBox(height: 8),
          for (final item in entry.value)
            _ItemTile(
              item: item,
              puedeGestionar: puedeGestionar,
              onMarcar: (r) => _marcar(ref, item, r),
              onObservacion: () => _editarObservacion(context, ref, item),
              onEliminar: () => _eliminarItem(ref, item.id),
            ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _ResumenBar extends StatelessWidget {
  const _ResumenBar(
      {required this.ok, required this.noOk, required this.pendientes, required this.total});

  final int ok;
  final int noOk;
  final int pendientes;
  final int total;

  @override
  Widget build(BuildContext context) {
    final (label, color) = noOk > 0
        ? ('Con observaciones', AppColors.critico)
        : pendientes > 0
            ? ('En progreso', AppColors.alerta)
            : ('Apto para servicio', AppColors.exito);
    return FireCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined, color: color),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.title.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Contador(valor: ok, label: 'OK', color: AppColors.exito),
              _Contador(valor: noOk, label: 'NO OK', color: AppColors.critico),
              _Contador(valor: pendientes, label: 'Pendientes', color: AppColors.textoTenue),
              _Contador(valor: total, label: 'Total', color: AppColors.textoPrincipal),
            ],
          ),
        ],
      ),
    );
  }
}

class _Contador extends StatelessWidget {
  const _Contador({required this.valor, required this.label, required this.color});

  final int valor;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$valor', style: AppTextStyles.title.copyWith(color: color, fontSize: 24)),
          Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SeccionHeader extends StatelessWidget {
  const _SeccionHeader({required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.relleno,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        titulo.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textoPrincipal,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.puedeGestionar,
    required this.onMarcar,
    required this.onObservacion,
    required this.onEliminar,
  });

  final ChecklistItem item;
  final bool puedeGestionar;
  final ValueChanged<ResultadoChecklistItem> onMarcar;
  final VoidCallback onObservacion;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FireCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(item.descripcion, style: AppTextStyles.body)),
                if (puedeGestionar)
                  InkWell(
                    onTap: onEliminar,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 18, color: AppColors.textoTenue),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _ResultBtn(
                  label: 'OK',
                  color: AppColors.exito,
                  seleccionado: item.resultado == ResultadoChecklistItem.cumple,
                  onTap: () => onMarcar(ResultadoChecklistItem.cumple),
                ),
                const SizedBox(width: 8),
                _ResultBtn(
                  label: 'NO OK',
                  color: AppColors.critico,
                  seleccionado: item.resultado == ResultadoChecklistItem.noCumple,
                  onTap: () => onMarcar(ResultadoChecklistItem.noCumple),
                ),
                const SizedBox(width: 8),
                _ResultBtn(
                  label: 'N/A',
                  color: AppColors.textoTenue,
                  seleccionado: item.resultado == ResultadoChecklistItem.noAplica,
                  onTap: () => onMarcar(ResultadoChecklistItem.noAplica),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    item.observacion != null && item.observacion!.isNotEmpty
                        ? Icons.sticky_note_2
                        : Icons.note_add_outlined,
                    size: 20,
                    color: item.observacion != null && item.observacion!.isNotEmpty
                        ? AppColors.info
                        : AppColors.textoTenue,
                  ),
                  onPressed: onObservacion,
                ),
              ],
            ),
            if (item.observacion != null && item.observacion!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Obs: ${item.observacion}', style: AppTextStyles.caption),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultBtn extends StatelessWidget {
  const _ResultBtn({
    required this.label,
    required this.color,
    required this.seleccionado,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: seleccionado ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: seleccionado ? color : AppColors.borde),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: seleccionado ? AppColors.blanco : color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _TextoDialog extends StatefulWidget {
  const _TextoDialog({required this.titulo, this.inicial});

  final String titulo;
  final String? inicial;

  @override
  State<_TextoDialog> createState() => _TextoDialogState();
}

class _TextoDialogState extends State<_TextoDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.inicial ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Texto'),
        maxLines: 3,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
