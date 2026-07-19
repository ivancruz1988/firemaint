import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/widgets/fire_button.dart';
import '../../auth/application/auth_providers.dart';

/// Permite al usuario logueado reemplazar su contrasena, tipicamente la
/// provisoria que le dio el administrador al crearle la cuenta.
class CambiarPasswordDialog extends ConsumerStatefulWidget {
  const CambiarPasswordDialog({super.key});

  @override
  ConsumerState<CambiarPasswordDialog> createState() => _CambiarPasswordDialogState();
}

class _CambiarPasswordDialogState extends ConsumerState<CambiarPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _actualController = TextEditingController();
  final _nuevaController = TextEditingController();
  final _repetirController = TextEditingController();
  bool _guardando = false;
  bool _oculta = true;

  @override
  void dispose() {
    _actualController.dispose();
    _nuevaController.dispose();
    _repetirController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await ref.read(authControllerProvider.notifier).cambiarPassword(
            actual: _actualController.text,
            nueva: _nuevaController.text,
          );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.exito,
          content: Text('Contrasena actualizada'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // El error tipico aca es la contrasena actual equivocada, que Supabase
      // devuelve como credenciales invalidas.
      final mensaje = e.toString().contains('Invalid login credentials')
          ? 'La contrasena actual no es correcta'
          : 'No se pudo cambiar la contrasena: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.critico, content: Text(mensaje)),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cambiar contrasena'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _actualController,
                decoration: InputDecoration(
                  labelText: 'Contrasena actual *',
                  suffixIcon: IconButton(
                    icon: Icon(_oculta ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _oculta = !_oculta),
                  ),
                ),
                obscureText: _oculta,
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nuevaController,
                decoration: const InputDecoration(labelText: 'Contrasena nueva *'),
                obscureText: _oculta,
                validator: (v) {
                  if (v == null || v.length < 6) return 'Minimo 6 caracteres';
                  if (v == _actualController.text) return 'Tiene que ser distinta a la actual';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _repetirController,
                decoration: const InputDecoration(labelText: 'Repetir contrasena nueva *'),
                obscureText: _oculta,
                validator: (v) =>
                    v != _nuevaController.text ? 'Las contrasenas no coinciden' : null,
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
          label: _guardando ? 'Guardando...' : 'Guardar',
          expand: false,
          onPressed: _guardando ? null : _guardar,
        ),
      ],
    );
  }
}
