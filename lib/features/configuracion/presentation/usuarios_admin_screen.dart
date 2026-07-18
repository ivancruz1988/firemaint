import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../application/usuarios_admin_providers.dart';
import 'usuario_form_dialog.dart';

class UsuariosAdminScreen extends ConsumerWidget {
  const UsuariosAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosAsync = ref.watch(usuariosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(context: context, builder: (_) => const UsuarioFormDialog()),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Nuevo usuario'),
      ),
      body: usuariosAsync.when(
        data: (usuarios) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: usuarios.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final usuario = usuarios[index];
            return FireCard(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.rojoBombero.withValues(alpha: 0.1),
                    child: const Icon(Icons.person_outline, color: AppColors.rojoBombero),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(usuario.nombreCompleto, style: AppTextStyles.title),
                        Text(usuario.email, style: AppTextStyles.label),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.amarilloSeguridad.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(usuario.rol.label,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('No se pudieron cargar los usuarios: $error')),
      ),
    );
  }
}
