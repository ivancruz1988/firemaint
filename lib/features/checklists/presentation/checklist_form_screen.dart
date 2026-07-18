import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/widgets/fire_button.dart';
import '../../../domain/entities/checklist.dart';
import '../application/checklists_providers.dart';

const _tiposVehiculo = ['general', 'autobomba', 'cisterna', 'rescate', 'pickup', 'otro'];

class ChecklistFormScreen extends ConsumerStatefulWidget {
  const ChecklistFormScreen({super.key, this.checklistId});

  final String? checklistId;

  @override
  ConsumerState<ChecklistFormScreen> createState() => _ChecklistFormScreenState();
}

class _ChecklistFormScreenState extends ConsumerState<ChecklistFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  String _tipoVehiculo = 'general';
  bool _activo = true;
  Checklist? _original;
  bool _cargando = false;
  bool _inicializado = false;

  bool get _esEdicion => widget.checklistId != null;

  void _cargarDesde(Checklist c) {
    _original = c;
    _nombreController.text = c.nombre;
    _descripcionController.text = c.descripcion ?? '';
    _tipoVehiculo = c.tipoVehiculo ?? 'general';
    _activo = c.activo;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      final checklist = Checklist(
        id: _original?.id ?? '',
        nombre: _nombreController.text.trim(),
        descripcion:
            _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
        tipoVehiculo: _tipoVehiculo,
        activo: _activo,
      );
      final guardado = await ref.read(checklistRepositoryProvider).upsert(checklist);
      ref.invalidate(checklistsListProvider);
      if (mounted) {
        if (_esEdicion) {
          ref.invalidate(checklistByIdProvider(guardado.id));
          context.pop();
        } else {
          // Tras crear, ir al detalle para cargar los items.
          context.pushReplacement('/checklists/${guardado.id}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No se pudo guardar el checklist: $e')));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_esEdicion && !_inicializado) {
      final checklistAsync = ref.watch(checklistByIdProvider(widget.checklistId!));
      return checklistAsync.when(
        data: (c) {
          if (c != null) {
            _cargarDesde(c);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_inicializado) setState(() => _inicializado = true);
            });
          }
          return _buildForm(context);
        },
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Editar checklist')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(title: const Text('Editar checklist')),
          body: Center(child: Text('No se pudo cargar: $error')),
        ),
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar checklist' : 'Nuevo checklist')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripcion'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _tipoVehiculo,
              decoration: const InputDecoration(labelText: 'Aplica a tipo de vehiculo'),
              items: [
                for (final t in _tiposVehiculo) DropdownMenuItem(value: t, child: Text(t)),
              ],
              onChanged: (value) => setState(() => _tipoVehiculo = value!),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Checklist activo'),
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
