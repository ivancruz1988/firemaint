import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/widgets/fire_button.dart';
import '../../../domain/entities/repuesto.dart';
import '../application/repuestos_providers.dart';

class RepuestoFormScreen extends ConsumerStatefulWidget {
  const RepuestoFormScreen({super.key, this.repuestoId});

  final String? repuestoId;

  @override
  ConsumerState<RepuestoFormScreen> createState() => _RepuestoFormScreenState();
}

class _RepuestoFormScreenState extends ConsumerState<RepuestoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _stockMinimoController = TextEditingController(text: '0');
  final _ubicacionController = TextEditingController();
  final _unidadController = TextEditingController(text: 'unidad');
  final _costoController = TextEditingController();

  Repuesto? _original;
  bool _cargando = false;
  bool _inicializado = false;

  bool get _esEdicion => widget.repuestoId != null;

  void _cargarDesde(Repuesto r) {
    _original = r;
    _codigoController.text = r.codigo;
    _descripcionController.text = r.descripcion;
    _stockController.text = r.stock.toString();
    _stockMinimoController.text = r.stockMinimo.toString();
    _ubicacionController.text = r.ubicacion ?? '';
    _unidadController.text = r.unidadMedida;
    _costoController.text = r.costoUnitario?.toString() ?? '';
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _descripcionController.dispose();
    _stockController.dispose();
    _stockMinimoController.dispose();
    _ubicacionController.dispose();
    _unidadController.dispose();
    _costoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      final repuesto = Repuesto(
        id: _original?.id ?? '',
        codigo: _codigoController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        stock: double.tryParse(_stockController.text.trim()) ?? 0,
        stockMinimo: double.tryParse(_stockMinimoController.text.trim()) ?? 0,
        ubicacion: _ubicacionController.text.trim().isEmpty ? null : _ubicacionController.text.trim(),
        unidadMedida: _unidadController.text.trim().isEmpty ? 'unidad' : _unidadController.text.trim(),
        costoUnitario: double.tryParse(_costoController.text.trim()),
        activo: _original?.activo ?? true,
      );
      final guardado = await ref.read(repuestoRepositoryProvider).upsert(repuesto);
      ref.invalidate(repuestosListProvider);
      if (_esEdicion) ref.invalidate(repuestoByIdProvider(guardado.id));
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No se pudo guardar el repuesto: $e')));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_esEdicion && !_inicializado) {
      final repuestoAsync = ref.watch(repuestoByIdProvider(widget.repuestoId!));
      return repuestoAsync.when(
        data: (r) {
          if (r != null) {
            _cargarDesde(r);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_inicializado) setState(() => _inicializado = true);
            });
          }
          return _buildForm(context);
        },
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Editar repuesto')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(title: const Text('Editar repuesto')),
          body: Center(child: Text('No se pudo cargar: $error')),
        ),
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar repuesto' : 'Nuevo repuesto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _codigoController,
              decoration: const InputDecoration(labelText: 'Codigo *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripcion *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(labelText: 'Stock actual'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stockMinimoController,
                    decoration: const InputDecoration(labelText: 'Stock minimo'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _unidadController,
                    decoration: const InputDecoration(labelText: 'Unidad de medida'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _costoController,
                    decoration: const InputDecoration(labelText: 'Costo unitario'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ubicacionController,
              decoration: const InputDecoration(labelText: 'Ubicacion'),
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
