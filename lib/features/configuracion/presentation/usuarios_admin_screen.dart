import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../../../domain/entities/usuario.dart';
import '../application/usuarios_admin_providers.dart';
import 'usuario_form_dialog.dart';

class UsuariosAdminScreen extends ConsumerWidget {
  const UsuariosAdminScreen({super.key});

  Future<void> _confirmarBaja(BuildContext context, WidgetRef ref, Usuario usuario) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Dar de baja'),
        content: Text(
          '${usuario.nombreCompleto} no va a poder ingresar mas a la aplicacion.\n\n'
          'Su nombre se mantiene en las ordenes, checklists y novedades que ya '
          'cargo. Podes reactivarlo cuando quieras.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.critico),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Dar de baja'),
          ),
        ],
      ),
    );

    if (confirmado != true || !context.mounted) return;
    await _aplicar(context, ref, usuario, activo: false);
  }

  Future<void> _aplicar(
    BuildContext context,
    WidgetRef ref,
    Usuario usuario, {
    required bool activo,
  }) async {
    await ref.read(usuariosAdminControllerProvider.notifier).setActivo(usuario.id, activo: activo);

    if (!context.mounted) return;
    final estado = ref.read(usuariosAdminControllerProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: estado.hasError ? AppColors.critico : AppColors.exito,
        content: Text(
          estado.hasError
              ? 'No se pudo aplicar el cambio: ${estado.error}'
              : activo
              ? '${usuario.nombreCompleto} fue reactivado'
              : '${usuario.nombreCompleto} fue dado de baja',
        ),
      ),
    );
  }

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
            final inactivo = !usuario.activo;

            return Opacity(
              opacity: inactivo ? 0.55 : 1,
              child: FireCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: (inactivo ? AppColors.textoTenue : AppColors.rojoBombero)
                          .withValues(alpha: 0.1),
                      child: Icon(
                        inactivo ? Icons.person_off_outlined : Icons.person_outline,
                        color: inactivo ? AppColors.textoTenue : AppColors.rojoBombero,
                      ),
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
                        color: (inactivo ? AppColors.textoTenue : AppColors.amarilloSeguridad)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        inactivo ? 'Inactivo' : usuario.rol.label,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                    PopupMenuButton<_AccionUsuario>(
                      tooltip: 'Acciones',
                      icon: const Icon(Icons.more_vert, color: AppColors.textoTenue),
                      onSelected: (accion) => switch (accion) {
                        _AccionUsuario.editar => showDialog(
                          context: context,
                          builder: (_) => UsuarioFormDialog(usuario: usuario),
                        ),
                        _AccionUsuario.reactivar => _aplicar(context, ref, usuario, activo: true),
                        _AccionUsuario.darDeBaja => _confirmarBaja(context, ref, usuario),
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: _AccionUsuario.editar,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Editar'),
                          ),
                        ),
                        if (inactivo)
                          const PopupMenuItem(
                            value: _AccionUsuario.reactivar,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.person_add_alt, color: AppColors.exito),
                              title: Text('Reactivar'),
                            ),
                          )
                        else
                          const PopupMenuItem(
                            value: _AccionUsuario.darDeBaja,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.person_off_outlined, color: AppColors.critico),
                              title: Text('Dar de baja'),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
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

enum _AccionUsuario { editar, reactivar, darDeBaja }
