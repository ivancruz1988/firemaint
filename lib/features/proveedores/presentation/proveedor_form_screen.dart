import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/widgets/fire_button.dart';
import '../../../domain/entities/proveedor.dart';
import '../application/proveedores_providers.dart';

class ProveedorFormScreen extends ConsumerStatefulWidget {
  const ProveedorFormScreen({super.key, this.proveedorId});
  final String? proveedorId;

  @override
  ConsumerState<ProveedorFormScreen> createState() => _ProveedorFormScreenState();
}

class _ProveedorFormScreenState extends ConsumerState<ProveedorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _rubro = TextEditingController();
  final _contacto = TextEditingController();
  final _telefono = TextEditingController();
  final _whatsapp = TextEditingController();
  final _email = TextEditingController();
  final _direccion = TextEditingController();
  final _localidad = TextEditingController();
  final _notas = TextEditingController();
  Proveedor? _original;
  bool _inicializado = false;
  bool _guardando = false;

  bool get _edicion => widget.proveedorId != null;
  String? _opcional(String texto) => texto.trim().isEmpty ? null : texto.trim();

  void _cargar(Proveedor p) {
    _original = p;
    _nombre.text = p.nombre;
    _rubro.text = p.rubro ?? '';
    _contacto.text = p.contacto ?? '';
    _telefono.text = p.telefono ?? '';
    _whatsapp.text = p.whatsapp ?? '';
    _email.text = p.email ?? '';
    _direccion.text = p.direccion ?? '';
    _localidad.text = p.localidad ?? '';
    _notas.text = p.notas ?? '';
  }

  @override
  void dispose() {
    for (final controller in [
      _nombre,
      _rubro,
      _contacto,
      _telefono,
      _whatsapp,
      _email,
      _direccion,
      _localidad,
      _notas,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final guardado = await ref
          .read(proveedorRepositoryProvider)
          .upsert(
            Proveedor(
              id: _original?.id ?? '',
              nombre: _nombre.text.trim(),
              rubro: _opcional(_rubro.text),
              contacto: _opcional(_contacto.text),
              telefono: _opcional(_telefono.text),
              whatsapp: _opcional(_whatsapp.text),
              email: _opcional(_email.text),
              direccion: _opcional(_direccion.text),
              localidad: _opcional(_localidad.text),
              notas: _opcional(_notas.text),
              activo: _original?.activo ?? true,
            ),
          );
      ref.invalidate(proveedoresListProvider);
      ref.invalidate(proveedorByIdProvider(guardado.id));
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_edicion && !_inicializado) {
      return ref
          .watch(proveedorByIdProvider(widget.proveedorId!))
          .when(
            data: (p) {
              if (p != null) {
                _cargar(p);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!_inicializado) setState(() => _inicializado = true);
                });
              }
              return _form();
            },
            loading: () => Scaffold(
              appBar: AppBar(title: const Text('Editar proveedor')),
              body: const Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Scaffold(
              appBar: AppBar(title: const Text('Editar proveedor')),
              body: Center(child: Text('No se pudo cargar: $error')),
            ),
          );
    }
    return _form();
  }

  Widget _form() => Scaffold(
    appBar: AppBar(title: Text(_edicion ? 'Editar proveedor' : 'Nuevo proveedor')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nombre,
            decoration: const InputDecoration(labelText: 'Nombre / empresa *'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Ingresá el nombre' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _rubro,
            decoration: const InputDecoration(
              labelText: 'Rubro (ej.: repuestos, neumáticos, electricidad)',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contacto,
            decoration: const InputDecoration(labelText: 'Persona de contacto'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _telefono,
            decoration: const InputDecoration(labelText: 'Teléfono'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _whatsapp,
            decoration: const InputDecoration(
              labelText: 'WhatsApp (con código de país, ej. 549...)',
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Correo electrónico'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _direccion,
            decoration: const InputDecoration(labelText: 'Dirección'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _localidad,
            decoration: const InputDecoration(labelText: 'Localidad'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notas,
            decoration: const InputDecoration(labelText: 'Notas'),
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          FireButton.primary(
            label: _guardando ? 'Guardando...' : 'Guardar proveedor',
            icon: Icons.save_outlined,
            onPressed: _guardando ? null : _guardar,
          ),
        ],
      ),
    ),
  );
}
