import 'package:flutter/material.dart';

import 'press_scale.dart';

/// Card institucional reutilizada en KPIs de dashboard, secciones de detalle
/// de vehiculo, y listados.
class FireCard extends StatelessWidget {
  const FireCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(padding: padding, child: child),
      ),
    );
    // Solo se anima al presionar si la tarjeta es interactiva.
    return onTap == null ? card : PressScale(child: card);
  }
}
