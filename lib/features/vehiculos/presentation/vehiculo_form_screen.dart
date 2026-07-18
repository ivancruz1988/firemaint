import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/widgets/fire_button.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/vehiculo.dart';
import '../../dashboard/application/dashboard_providers.dart';
import '../application/vehiculos_providers.dart';

class VehiculoFormScreen extends ConsumerStatefulWidget {
  const VehiculoFormScreen({super.key, this.vehiculoId});

  /// Si es null, la pantalla es de alta. Si trae un id, es de edicion.
  final String? vehiculoId;

  @override
  ConsumerState<VehiculoFormScreen> createState() => _VehiculoFormScreenState();
}

class _VehiculoFormScreenState extends ConsumerState<VehiculoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroInternoController = TextEditingController();
  final _dominioController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anioController = TextEditingController();
  final _kilometrajeController = TextEditingController(text: '0');
  final _horasBombaController = TextEditingController(text: '0');
  final _observacionesController = TextEditingController();

  TipoVehiculo _tipo = TipoVehiculo.autobomba;
  EstadoVehiculo _estado = EstadoVehiculo.operativo;
  DateTime _fechaAlta = DateTime.now();
  Vehiculo? _original;
  bool _cargando = false;
  bool _inicializado = false;

  bool get _esEdicion => widget.vehiculoId != null;

  void _cargarDesde(Vehiculo vehiculo) {
    _original = vehiculo;
    _numeroInternoController.text = vehiculo.numeroInterno;
    _dominioController.text = vehiculo.dominio ?? '';
    _marcaController.text = vehiculo.marca;
    _modeloController.text = vehiculo.modelo;
    _anioController.text = vehiculo.anio?.toString() ?? '';
    _kilometrajeController.text = vehiculo.kilometraje.toString();
    _horasBombaController.text = vehiculo.horasBomba.toString();
    _observacionesController.text = vehiculo.observaciones ?? '';
    _tipo = vehiculo.tipo;
    _estado = vehiculo.estadoOperativo;
    _fechaAlta = vehiculo.fechaAlta;
  }

  @override
  void dispose() {
    _numeroInternoController.dispose();
    _dominioController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _kilometrajeController.dispose();
    _horasBombaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaAlta,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (seleccionada != null) setState(() => _fechaAlta = seleccionada);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      final vehiculo = Vehiculo(
        id: _original?.id ?? '',
        numeroInterno: _numeroInternoController.text.trim(),
        dominio: _dominioController.text.trim().isEmpty ? null : _dominioController.text.trim(),
        marca: _marcaController.text.trim(),
        modelo: _modeloController.text.trim(),
        anio: int.tryParse(_anioController.text.trim()),
        tipo: _tipo,
        kilometraje: double.tryParse(_kilometrajeController.text.trim()) ?? 0,
        horasBomba: double.tryParse(_horasBombaController.text.trim()) ?? 0,
        fechaAlta: _fechaAlta,
        estadoOperativo: _estado,
        observaciones:
            _observacionesController.text.trim().isEmpty ? null : _observacionesController.text.trim(),
        fechaCreacion: _original?.fechaCreacion ?? DateTime.now(),
        fechaModificacion: DateTime.now(),
      );

      final guardado = await ref.read(vehiculoRepositoryProvider).upsert(vehiculo);

      ref.invalidate(vehiculosListProvider);
      ref.invalidate(dashboardKpisProvider);
      if (_esEdicion) ref.invalidate(vehiculoByIdProvider(guardado.id));

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar el vehiculo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_esEdicion && !_inicializado) {
      final vehiculoAsync = ref.watch(vehiculoByIdProvider(widget.vehiculoId!));
      return vehiculoAsync.when(
        data: (vehiculo) {
          if (vehiculo != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_inicializado) setState(() => _inicializado = true);
            });
            _cargarDesde(vehiculo);
          }
          return _buildForm(context);
        },
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Editar vehiculo')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(title: const Text('Editar vehiculo')),
          body: Center(child: Text('No se pudo cargar el vehiculo: $error')),
        ),
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar vehiculo' : 'Nuevo vehiculo')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _numeroInternoController,
              decoration: const InputDecoration(labelText: 'Numero interno *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dominioController,
              decoration: const InputDecoration(labelText: 'Dominio (patente)'),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _marcaController,
                    decoration: const InputDecoration(labelText: 'Marca *'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _modeloController,
                    decoration: const InputDecoration(labelText: 'Modelo *'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _anioController,
              decoration: const InputDecoration(labelText: 'Anio'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TipoVehiculo>(
              initialValue: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo de vehiculo *'),
              items: [
                for (final tipo in TipoVehiculo.values)
                  DropdownMenuItem(value: tipo, child: Text(tipo.label)),
              ],
              onChanged: (value) => setState(() => _tipo = value!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EstadoVehiculo>(
              initialValue: _estado,
              decoration: const InputDecoration(labelText: 'Estado operativo *'),
              items: [
                for (final estado in EstadoVehiculo.values)
                  DropdownMenuItem(value: estado, child: Text(estado.label)),
              ],
              onChanged: (value) => setState(() => _estado = value!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _kilometrajeController,
                    decoration: const InputDecoration(labelText: 'Kilometraje'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _horasBombaController,
                    decoration: const InputDecoration(labelText: 'Horas de bomba'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _seleccionarFecha,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Fecha de alta'),
                child: Text(formatDate(_fechaAlta)),
              ),
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
