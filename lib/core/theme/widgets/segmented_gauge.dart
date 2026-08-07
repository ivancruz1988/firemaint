import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Barra segmentada (10 pasos por defecto) para niveles y stock, en vez de
/// un degradado continuo: da la lectura tipo "gauge digital" del sistema de
/// diseno "Operaciones de Flota".
class SegmentedGauge extends StatelessWidget {
  const SegmentedGauge({
    super.key,
    required this.value,
    this.segments = 10,
    this.color = AppColors.exito,
    this.height = 8,
  });

  /// Fraccion 0..1 de segmentos llenos. Se clampea internamente.
  final double value;
  final int segments;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final llenos = (value.clamp(0, 1) * segments).round();
    return Row(
      children: [
        for (var i = 0; i < segments; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          Expanded(
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: i < llenos ? color : AppColors.relleno,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
