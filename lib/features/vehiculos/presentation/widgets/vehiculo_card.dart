import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/fire_card.dart';
import '../../../../core/theme/widgets/status_badge.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../domain/entities/vehiculo.dart';

class VehiculoCard extends StatelessWidget {
  const VehiculoCard({super.key, required this.vehiculo, required this.onTap});

  final Vehiculo vehiculo;
  final VoidCallback onTap;

  // Protocolo semaforo del sistema de diseno: la Status Bar de la tarjeta
  // repite el mismo color que ya usa el StatusBadge para este estado.
  Color _colorEstado() => switch (vehiculo.estadoOperativo) {
    EstadoVehiculo.operativo => AppColors.exito,
    EstadoVehiculo.enMantenimiento => AppColors.alerta,
    EstadoVehiculo.fueraDeServicio => AppColors.critico,
  };

  @override
  Widget build(BuildContext context) {
    return FireCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Bar: linea de 4px en el borde superior de la tarjeta.
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: _colorEstado(),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.rojoBombero.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_shipping, color: AppColors.rojoBombero, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehiculo.numeroInterno} — ${vehiculo.marca} ${vehiculo.modelo}',
                        style: AppTextStyles.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(vehiculo.dominio ?? 'Sin dominio', style: AppTextStyles.label),
                    ],
                  ),
                ),
                StatusBadge.estadoOperativo(vehiculo.estadoOperativo.toDb()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
