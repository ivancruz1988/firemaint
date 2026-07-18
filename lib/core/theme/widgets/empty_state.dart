import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

/// Estado vacio reutilizable: icono grande atenuado + titulo + mensaje.
/// Se usa en todos los listados cuando no hay datos, para dar una sensacion
/// consistente y cuidada en lugar de un texto suelto.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.titulo,
    this.mensaje,
  });

  final IconData icon;
  final String titulo;
  final String? mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.grisClaro,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: AppColors.textoTenue),
            ),
            const SizedBox(height: 16),
            Text(titulo, style: AppTextStyles.title, textAlign: TextAlign.center),
            if (mensaje != null) ...[
              const SizedBox(height: 6),
              Text(mensaje!, style: AppTextStyles.label, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
