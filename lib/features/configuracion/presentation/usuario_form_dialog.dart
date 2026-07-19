import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/widgets/fire_button.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/usuario.dart';
import '../application/usuarios_admin_providers.dart';

/// Alta y edicion de usuarios por parte de un administrador.
///
/// El alta invoca la Edge Function `create-user` (necesita la service role
/// key). La edicion escribe directo en la tabla, donde las reglas de la base
/// ya limitan quien puede tocar el rol.
class UsuarioFormDialog extends ConsumerStatefulWidget {
  const UsuarioFormDialog({super.key, this.usuario});

  /// Si viene, el dialogo edita ese usuario en lugar de crear uno nuevo.
  final Usuario? usuario;

  @override
  ConsumerState<UsuarioFormDialog> createState() => _UsuarioFormDialogState();
}

class _UsuarioFormDialogState extends ConsumerState<UsuarioFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefonoController;
  final _passwordController = TextEditingController();
  late UserRole _rol;
  bool _guardando = false;

  bool get _esEdicion => widget.usuario != null;

  @override
  void initState() {
    super.initState();
    final u = widget.usuario;
    _nombreController = TextEditingController(text: u?.nombreCompleto ?? '');
    _emailController = TextEditingController(text: u?.email ?? '');
    _telefonoController = TextEditingController(text: u?.telefono ?? '');
    _rol = u?.rol ?? UserRole.tecnico;
  }

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

    final repo = ref.read(usuarioRepositoryProvider);
    final telefono = _telefonoController.text.trim().isEmpty
        ? null
        : _telefonoController.text.trim();

    try {
      if (_esEdicion) {
        await repo.actualizarUsuario(
          id: widget.usuario!.id,
          nombreCompleto: _nombreController.text.trim(),
          rol: _rol,
          telefono: telefono,
        );
      } else {
        await repo.crearUsuario(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          nombreCompleto: _nombreController.text.trim(),
          rol: _rol,
          telefono: telefono,
        );
      }
      ref.invalidate(usuariosProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _esEdicion ? 'No se pudo guardar el cambio: $e' : 'No se pudo crear el usuario: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_esEdicion ? 'Editar usuario' : 'Nuevo usuario'),
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
                // El correo identifica la cuenta en auth.users: cambiarlo solo
                // en esta tabla dejaria al usuario sin poder iniciar sesion.
                enabled: !_esEdicion,
                decoration: InputDecoration(
                  labelText: 'Correo electronico *',
                  helperText: _esEdicion ? 'El correo no se puede modificar' : null,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              if (!_esEdicion) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contrasena temporal *'),
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 6) ? 'Minimo 6 caracteres' : null,
                ),
              ],
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
          label: _guardando
              ? 'Guardando...'
              : _esEdicion
              ? 'Guardar'
              : 'Crear',
          expand: false,
          onPressed: _guardando ? null : _guardar,
        ),
      ],
    );
  }
}
