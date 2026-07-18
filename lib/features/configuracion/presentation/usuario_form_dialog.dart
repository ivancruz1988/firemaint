import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/widgets/fire_button.dart';
import '../../../domain/entities/enums.dart';
import '../application/usuarios_admin_providers.dart';

/// Formulario para que un administrador cree un nuevo usuario (invoca la
/// Edge Function `create-user`, ya que requiere la service role key).
class UsuarioFormDialog extends ConsumerStatefulWidget {
  const UsuarioFormDialog({super.key});

  @override
  ConsumerState<UsuarioFormDialog> createState() => _UsuarioFormDialogState();
}

class _UsuarioFormDialogState extends ConsumerState<UsuarioFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telefonoController = TextEditingController();
  UserRole _rol = UserRole.tecnico;
  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await ref.read(usuarioRepositoryProvider).crearUsuario(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            nombreCompleto: _nombreController.text.trim(),
            rol: _rol,
            telefono: _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
          );
      ref.invalidate(usuariosProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo crear el usuario: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo usuario'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre completo *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo electronico *'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contrasena temporal *'),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Minimo 6 caracteres' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Telefono'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<UserRole>(
                initialValue: _rol,
                decoration: const InputDecoration(labelText: 'Rol *'),
                items: [
                  for (final rol in UserRole.values)
                    DropdownMenuItem(value: rol, child: Text(rol.label)),
                ],
                onChanged: (value) => setState(() => _rol = value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FireButton.primary(
          label: _guardando ? 'Creando...' : 'Crear',
          expand: false,
          onPressed: _guardando ? null : _guardar,
        ),
      ],
    );
  }
}
