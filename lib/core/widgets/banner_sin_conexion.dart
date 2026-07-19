import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connectivity/connectivity_providers.dart';
import '../theme/app_colors.dart';

/// Aviso persistente, visible en toda la app, de que no hay conexion.
///
/// No bloquea la navegacion: el usuario puede seguir mirando datos ya
/// cargados. Sirve para que, si algo falla al guardar, no sea una sorpresa.
class BannerSinConexion extends ConsumerWidget {
  const BannerSinConexion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(estaOnlineProvider);
    if (online) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: AppColors.critico,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 14, color: AppColors.blanco),
          SizedBox(width: 6),
          Text(
            'Sin conexion a internet',
            style: TextStyle(color: AppColors.blanco, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
