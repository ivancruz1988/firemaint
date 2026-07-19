import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/widgets/fire_card.dart';
import '../../../../core/theme/widgets/status_badge.dart';
import '../../../../domain/entities/vehiculo.dart';

class VehiculoCard extends StatelessWidget {
  const VehiculoCard({super.key, required this.vehiculo, required this.onTap});

  final Vehiculo vehiculo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FireCard(
      onTap: onTap,
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
    );
  }
}
