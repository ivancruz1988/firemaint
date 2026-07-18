import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/lookup_providers.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/widgets/fire_button.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/novedad.dart';
import '../application/novedades_providers.dart';

class NovedadFormScreen extends ConsumerStatefulWidget {
  const NovedadFormScreen({super.key});

  @override
  ConsumerState<NovedadFormScreen> createState() => _NovedadFormScreenState();
}

class _NovedadFormScreenState extends ConsumerState<NovedadFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  String? _vehiculoId;
  TipoNovedad _tipo = TipoNovedad.averia;
  EstadoNovedad _estado = EstadoNovedad.abierta;
  DateTime _fechaOcurrencia = DateTime.now();
  bool _cargando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaOcurrencia,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (seleccionada != null) setState(() => _fechaOcurrencia = seleccionada);
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
      final novedad = Novedad(
        id: '',
        vehiculoId: _vehiculoId!,
        tipo: _tipo,
        titulo: _tituloController.text.trim(),
        descripcion:
            _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
        fechaOcurrencia: _fechaOcurrencia,
        estado: _estado,
      );
      await ref.read(novedadRepositoryProvider).upsert(novedad);
      ref.invalidate(novedadesListProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No se pudo guardar la novedad: $e')));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehiculosAsync = ref.watch(vehiculosLookupProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportar novedad')),
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
            DropdownButtonFormField<TipoNovedad>(
              initialValue: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo *'),
              items: [
                for (final t in TipoNovedad.values) DropdownMenuItem(value: t, child: Text(t.label)),
              ],
              onChanged: (value) => setState(() => _tipo = value!),
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
            DropdownButtonFormField<EstadoNovedad>(
              initialValue: _estado,
              decoration: const InputDecoration(labelText: 'Estado *'),
              items: [
                for (final e in EstadoNovedad.values)
                  DropdownMenuItem(value: e, child: Text(e.label)),
              ],
              onChanged: (value) => setState(() => _estado = value!),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _seleccionarFecha,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Fecha de ocurrencia'),
                child: Text(formatDate(_fechaOcurrencia)),
              ),
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
