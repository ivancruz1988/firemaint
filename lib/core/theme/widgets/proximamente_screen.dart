import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

/// Pantalla placeholder para modulos que todavia no tienen funcionalidad
/// (se completan en fases siguientes). Deja la navegacion ya armada.
class ProximamenteScreen extends StatelessWidget {
  const ProximamenteScreen({super.key, required this.titulo, required this.icono});

  final String titulo;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 72, color: AppColors.textoPrincipal.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(titulo, style: AppTextStyles.title),
            const SizedBox(height: 8),
            const Text('Proximamente', style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }
}
