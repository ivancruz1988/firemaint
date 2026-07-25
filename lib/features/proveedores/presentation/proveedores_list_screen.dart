import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/widgets/empty_state.dart';
import '../../../core/theme/widgets/fire_card.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/proveedor.dart';
import '../../auth/application/auth_providers.dart';
import '../application/proveedores_providers.dart';

class ProveedoresListScreen extends ConsumerWidget {
  const ProveedoresListScreen({super.key});

  bool _puedeGestionar(UserRole? rol) =>
      rol == UserRole.administrador || rol == UserRole.jefeTaller;

  Future<void> _abrir(BuildContext context, Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir la aplicación de contacto.'),
        ),
      );
    }
  }

  String _numeroWhatsapp(String numero) =>
      numero.replaceAll(RegExp(r'[^0-9]'), '');

  Future<void> _confirmarBorrado(
    BuildContext context,
    WidgetRef ref,
    Proveedor p,
  ) async {
    final borrar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar proveedor'),
        content: Text('¿Querés eliminar a ${p.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.critico),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (borrar != true) return;
    try {
      await ref.read(proveedorRepositoryProvider).delete(p.id);
      ref.invalidate(proveedoresListProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar el proveedor.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proveedores = ref.watch(proveedoresListProvider);
    final rol = ref.watch(currentRoleProvider);
    final puedeGestionar = _puedeGestionar(rol);
    final esAdmin = rol == UserRole.administrador;

    return Scaffold(
      appBar: AppBar(title: const Text('Proveedores')),
      floatingActionButton: puedeGestionar
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/proveedores/nuevo'),
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Nuevo proveedor'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: TextField(
              onChanged: (valor) =>
                  ref.read(proveedorBusquedaProvider.notifier).state = valor,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar por nombre, rubro, contacto o localidad',
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(proveedoresListProvider),
              child: proveedores.when(
                data: (lista) {
                  if (lista.isEmpty) {
                    return ListView(
                      children: const [
                        EmptyState(
                          icon: Icons.storefront_outlined,
                          titulo: 'Sin proveedores',
                          mensaje:
                              'Guardá acá los contactos de repuestos, talleres y servicios.',
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: lista.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final p = lista[index];
                      return FireCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.rojoBombero
                                      .withValues(alpha: .15),
                                  child: const Icon(
                                    Icons.storefront_outlined,
                                    color: AppColors.rojoBombero,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.nombre,
                                        style: AppTextStyles.title,
                                      ),
                                      if (p.rubro?.isNotEmpty == true)
                                        Text(
                                          p.rubro!,
                                          style: AppTextStyles.label,
                                        ),
                                    ],
                                  ),
                                ),
                                if (puedeGestionar)
                                  IconButton(
                                    tooltip: 'Editar',
                                    onPressed: () => context.push(
                                      '/proveedores/${p.id}/editar',
                                    ),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                if (esAdmin)
                                  IconButton(
                                    tooltip: 'Eliminar',
                                    onPressed: () =>
                                        _confirmarBorrado(context, ref, p),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppColors.critico,
                                    ),
                                  ),
                              ],
                            ),
                            if (p.contacto?.isNotEmpty == true ||
                                p.localidad?.isNotEmpty == true) ...[
                              const SizedBox(height: 10),
                              Text(
                                [p.contacto, p.localidad]
                                    .whereType<String>()
                                    .where((e) => e.isNotEmpty)
                                    .join(' · '),
                                style: AppTextStyles.label,
                              ),
                            ],
                            if (p.telefono?.isNotEmpty == true ||
                                p.whatsapp?.isNotEmpty == true ||
                                p.email?.isNotEmpty == true) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  if (p.telefono?.isNotEmpty == true)
                                    OutlinedButton.icon(
                                      onPressed: () => _abrir(
                                        context,
                                        Uri(scheme: 'tel', path: p.telefono),
                                      ),
                                      icon: const Icon(Icons.call_outlined),
                                      label: const Text('Llamar'),
                                    ),
                                  if (p.whatsapp?.isNotEmpty == true)
                                    FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF25D366,
                                        ),
                                      ),
                                      onPressed: () => _abrir(
                                        context,
                                        Uri.https(
                                          'wa.me',
                                          '/${_numeroWhatsapp(p.whatsapp!)}',
                                        ),
                                      ),
                                      icon: const Icon(Icons.chat_outlined),
                                      label: const Text('WhatsApp'),
                                    ),
                                  if (p.email?.isNotEmpty == true)
                                    OutlinedButton.icon(
                                      onPressed: () => _abrir(
                                        context,
                                        Uri(scheme: 'mailto', path: p.email),
                                      ),
                                      icon: const Icon(Icons.email_outlined),
                                      label: const Text('Correo'),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('No se pudieron cargar los proveedores: $error'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
