import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Franja de rayas diagonales 45°, tomada del sistema de diseno "Operaciones
/// de Flota": headers de seccion (amarillo sobre fondo oscuro, uso normal) y
/// overlay del boton critico (negro semitransparente sobre rojo, [opacity]
/// bajo y [gapColor] transparente).
class HazardStripes extends StatelessWidget {
  const HazardStripes({
    super.key,
    this.height,
    this.stripeColor = AppColors.amarilloSeguridad,
    this.gapColor = Colors.black,
    this.stripeWidth = 7,
    this.opacity = 1,
  });

  final double? height;
  final Color stripeColor;
  final Color gapColor;
  final double stripeWidth;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          painter: _HazardStripesPainter(
            stripeColor: stripeColor,
            gapColor: gapColor,
            stripeWidth: stripeWidth,
          ),
        ),
      ),
    );
  }
}

class _HazardStripesPainter extends CustomPainter {
  _HazardStripesPainter({required this.stripeColor, required this.gapColor, required this.stripeWidth});

  final Color stripeColor;
  final Color gapColor;
  final double stripeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..color = gapColor);

    // Se dibuja un area cuadrada mas grande que la diagonal del widget,
    // rotada 45 grados, para que las rayas cubran todo el rectangulo visible
    // sin dejar huecos en las puntas.
    final diagonal = size.width + size.height;
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.7853981633974483); // -45 grados
    canvas.translate(-diagonal / 2, -diagonal / 2);

    final paint = Paint()..color = stripeColor;
    for (var x = 0.0; x < diagonal; x += stripeWidth * 2) {
      canvas.drawRect(Rect.fromLTWH(x, 0, stripeWidth, diagonal), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HazardStripesPainter oldDelegate) =>
      oldDelegate.stripeColor != stripeColor ||
      oldDelegate.gapColor != gapColor ||
      oldDelegate.stripeWidth != stripeWidth;
}
