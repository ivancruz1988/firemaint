import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/lookup_providers.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/widgets/fire_button.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/mantenimiento_programado.dart';
import '../application/mantenimiento_providers.dart';

class MantenimientoFormScreen extends ConsumerStatefulWidget {
  const MantenimientoFormScreen({super.key, this.mantenimientoId});

  final String? mantenimientoId;

  @override
  ConsumerState<MantenimientoFormScreen> createState() => _MantenimientoFormScreenState();
}

class _MantenimientoFormScreenState extends ConsumerState<MantenimientoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  String? _vehiculoId;
  Frecuencia _frecuencia = Frecuencia.mensual;
  DateTime _proximaFecha = DateTime.now().add(const Duration(days: 30));
  bool _activo = true;
  MantenimientoProgramado? _original;
  bool _cargando = false;
  bool _inicializado = false;

  bool get _esEdicion => widget.mantenimientoId != null;

  void _cargarDesde(MantenimientoProgramado m) {
    _original = m;
    _nombreController.text = m.nombre;
    _descripcionController.text = m.descripcion ?? '';
    _vehiculoId = m.vehiculoId;
    _frecuencia = m.frecuencia;
    _proximaFecha = m.proximaFecha;
    _activo = m.activo;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: _proximaFecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (seleccionada != null) setState(() => _proximaFecha = seleccionada);
  }

  Future<void> _eliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar plan'),
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
      await ref.read(mantenimientoProgramadoRepositoryProvider).delete(widget.mantenimientoId!);
      ref.invalidate(mantenimientosListProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No se pudo eliminar: $e')));
      }
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_vehiculoId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecciona un vehiculo')));
      return;
    }
    setState(() => _cargando = true);
    try {
      final m = MantenimientoProgramado(
        id: _original?.id ?? '',
        vehiculoId: _vehiculoId!,
        checklistId: _original?.checklistId,
        nombre: _nombreController.text.trim(),
        descripcion:
            _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
        frecuencia: _frecuencia,
        proximaFecha: _proximaFecha,
        ultimaFechaEjecucion: _original?.ultimaFechaEjecucion,
        activo: _activo,
      );
      final guardado = await ref.read(mantenimientoProgramadoRepositoryProvider).upsert(m);
      ref.invalidate(mantenimientosListProvider);
      if (_esEdicion) ref.invalidate(mantenimientoByIdProvider(guardado.id));
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No se pudo guardar el plan: $e')));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_esEdicion && !_inicializado) {
      final mantAsync = ref.watch(mantenimientoByIdProvider(widget.mantenimientoId!));
      return mantAsync.when(
        data: (m) {
          if (m != null) {
            _cargarDesde(m);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_inicializado) setState(() => _inicializado = true);
            });
          }
          return _buildForm(context);
        },
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Editar plan')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(title: const Text('Editar plan')),
          body: Center(child: Text('No se pudo cargar: $error')),
        ),
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final vehiculosAsync = ref.watch(vehiculosLookupProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar plan' : 'Nuevo plan'),
        actions: [
          if (_esEdicion)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _eliminar),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            vehiculosAsync.when(
              data: (vehiculos) => DropdownButtonFormField<String>(
                initialValue: _vehiculoId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Vehiculo *'),
                items: [
                  for (final v in vehiculos)
                    DropdownMenuItem(
                      value: v.id,
                      child: Text('${v.numeroInterno} · ${v.marca} ${v.modelo}',
                          overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (value) => setState(() => _vehiculoId = value),
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error cargando vehiculos: $e'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del plan *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripcion'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Frecuencia>(
              initialValue: _frecuencia,
              decoration: const InputDecoration(labelText: 'Frecuencia *'),
              items: [
                for (final f in Frecuencia.values) DropdownMenuItem(value: f, child: Text(f.label)),
              ],
              onChanged: (value) => setState(() => _frecuencia = value!),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _seleccionarFecha,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Proxima fecha'),
                child: Text(formatDate(_proximaFecha)),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Plan activo'),
              value: _activo,
              onChanged: (v) => setState(() => _activo = v),
            ),
            const SizedBox(height: 24),
            FireButton.primary(
              label: _cargando ? 'Guardando...' : 'Guardar',
              icon: Icons.save_outlined,
              onPressed: _cargando ? null : _guardar,
            ),
          ],
        ),
      ),
    );
  }
}
