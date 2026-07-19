import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/fire_button.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../../../domain/entities/enums.dart';
import '../../auth/application/auth_providers.dart';
import 'cambiar_password_dialog.dart';

class ConfiguracionScreen extends ConsumerWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarioAsync = ref.watch(currentUsuarioProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuracion')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          usuarioAsync.when(
            data: (usuario) {
              if (usuario == null) return const SizedBox.shrink();
              return FireCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.rojoBombero.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, color: AppColors.rojoBombero, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(usuario.nombreCompleto, style: AppTextStyles.title),
                          Text(usuario.email, style: AppTextStyles.label),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.amarilloSeguridad.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              usuario.rol.label,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('No se pudo cargar el usuario: $error'),
          ),
          const SizedBox(height: 16),
          FireCard(
            onTap: () =>
                showDialog(context: context, builder: (_) => const CambiarPasswordDialog()),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: AppColors.textoPrincipal),
                SizedBox(width: 12),
                Expanded(child: Text('Cambiar contrasena', style: AppTextStyles.title)),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (usuarioAsync.value?.rol == UserRole.administrador)
            FireCard(
              onTap: () => context.push('/configuracion/usuarios'),
              child: const Row(
                children: [
                  Icon(Icons.group_outlined, color: AppColors.textoPrincipal),
                  SizedBox(width: 12),
                  Expanded(child: Text('Gestion de usuarios', style: AppTextStyles.title)),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
          const SizedBox(height: 24),
          FireButton.danger(
            label: 'Cerrar sesion',
            icon: Icons.logout,
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}
