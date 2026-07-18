import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/lookup_providers.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/widgets/fire_button.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/orden_trabajo.dart';
import '../application/ordenes_trabajo_providers.dart';

class OrdenTrabajoFormScreen extends ConsumerStatefulWidget {
  const OrdenTrabajoFormScreen({super.key, this.ordenId});

  final String? ordenId;

  @override
  ConsumerState<OrdenTrabajoFormScreen> createState() => _OrdenTrabajoFormScreenState();
}

class _OrdenTrabajoFormScreenState extends ConsumerState<OrdenTrabajoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _horasController = TextEditingController();
  final _costoEstimadoController = TextEditingController();
  final _costoRealController = TextEditingController();
  final _observacionesController = TextEditingController();

  String? _vehiculoId;
  String? _tecnicoId;
  PrioridadOt _prioridad = PrioridadOt.media;
  EstadoOt _estado = EstadoOt.pendiente;
  OrdenTrabajo? _original;
  bool _cargando = false;
  bool _inicializado = false;

  bool get _esEdicion => widget.ordenId != null;

  void _cargarDesde(OrdenTrabajo ot) {
    _original = ot;
    _tituloController.text = ot.titulo;
    _descripcionController.text = ot.descripcion ?? '';
    _horasController.text = ot.horasTrabajo?.toString() ?? '';
    _costoEstimadoController.text = ot.costoEstimado?.toString() ?? '';
    _costoRealController.text = ot.costoReal?.toString() ?? '';
    _observacionesController.text = ot.observaciones ?? '';
    _vehiculoId = ot.vehiculoId;
    _tecnicoId = ot.tecnicoAsignadoId;
    _prioridad = ot.prioridad;
    _estado = ot.estado;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _horasController.dispose();
    _costoEstimadoController.dispose();
    _costoRealController.dispose();
    _observacionesController.dispose();
    super.dispose();
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
      final ot = OrdenTrabajo(
        id: _original?.id ?? '',
        numeroOt: _original?.numeroOt ?? 0,
        vehiculoId: _vehiculoId!,
        titulo: _tituloController.text.trim(),
        descripcion:
            _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
        prioridad: _prioridad,
        estado: _estado,
        tecnicoAsignadoId: _tecnicoId,
        horasTrabajo: double.tryParse(_horasController.text.trim()),
        costoEstimado: double.tryParse(_costoEstimadoController.text.trim()),
        costoReal: double.tryParse(_costoRealController.text.trim()),
        fechaInicio: _original?.fechaInicio,
        fechaFin: _original?.fechaFin,
        observaciones: _observacionesController.text.trim().isEmpty
            ? null
            : _observacionesController.text.trim(),
        fechaCreacion: _original?.fechaCreacion ?? DateTime.now(),
      );

      final guardado = await ref.read(ordenTrabajoRepositoryProvider).upsert(ot);
      ref.invalidate(ordenesTrabajoListProvider);
      if (_esEdicion) ref.invalidate(ordenTrabajoByIdProvider(guardado.id));
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No se pudo guardar la OT: $e')));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_esEdicion && !_inicializado) {
      final otAsync = ref.watch(ordenTrabajoByIdProvider(widget.ordenId!));
      return otAsync.when(
        data: (ot) {
          if (ot != null) {
            _cargarDesde(ot);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_inicializado) setState(() => _inicializado = true);
            });
          }
          return _buildForm(context);
        },
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Editar OT')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(title: const Text('Editar OT')),
          body: Center(child: Text('No se pudo cargar la OT: $error')),
        ),
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final vehiculosAsync = ref.watch(vehiculosLookupProvider);
    final tecnicosAsync = ref.watch(tecnicosProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar OT' : 'Nueva OT')),
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
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Titulo *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripcion'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PrioridadOt>(
              initialValue: _prioridad,
              decoration: const InputDecoration(labelText: 'Prioridad *'),
              items: [
                for (final p in PrioridadOt.values)
                  DropdownMenuItem(value: p, child: Text(p.label)),
              ],
              onChanged: (value) => setState(() => _prioridad = value!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EstadoOt>(
              initialValue: _estado,
              decoration: const InputDecoration(labelText: 'Estado *'),
              items: [
                for (final e in EstadoOt.values) DropdownMenuItem(value: e, child: Text(e.label)),
              ],
              onChanged: (value) => setState(() => _estado = value!),
            ),
            const SizedBox(height: 12),
            tecnicosAsync.when(
              data: (tecnicos) => DropdownButtonFormField<String?>(
                initialValue: _tecnicoId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Tecnico asignado'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Sin asignar')),
                  for (final t in tecnicos)
                    DropdownMenuItem(value: t.id, child: Text(t.nombreCompleto)),
                ],
                onChanged: (value) => setState(() => _tecnicoId = value),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error cargando tecnicos: $e'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _horasController,
              decoration: const InputDecoration(labelText: 'Horas de trabajo'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _costoEstimadoController,
                    decoration: const InputDecoration(labelText: 'Costo estimado'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _costoRealController,
                    decoration: const InputDecoration(labelText: 'Costo real'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _observacionesController,
              decoration: const InputDecoration(labelText: 'Observaciones'),
              maxLines: 3,
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
