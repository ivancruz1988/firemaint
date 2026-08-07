import 'package:flutter/material.dart';

import '../app_colors.dart';
import 'hazard_stripes.dart';
import 'press_scale.dart';

enum _FireButtonVariant { primary, secondary, danger }

/// Boton grande (alto 64) pensado para uso en taller con guantes.
/// Variantes: [FireButton.primary] (rojo), [FireButton.secondary] (amarillo),
/// [FireButton.danger] (rojo con overlay de rayas de peligro, "Critical
/// Action" del sistema de diseno: para acciones destructivas o cerrar sesion).
class FireButton extends StatelessWidget {
  const FireButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  }) : _variant = _FireButtonVariant.primary;

  const FireButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  }) : _variant = _FireButtonVariant.secondary;

  const FireButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  }) : _variant = _FireButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final _FireButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    final Widget button;
    switch (_variant) {
      case _FireButtonVariant.primary:
        button = _filled(AppColors.rojoBombero, AppColors.blanco);
      case _FireButtonVariant.secondary:
        button = _filled(AppColors.amarilloSeguridad, AppColors.textoPrincipal);
      case _FireButtonVariant.danger:
        button = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              _filled(AppColors.rojoBombero, AppColors.blanco),
              // Overlay decorativo: no debe interceptar el tap del boton.
              const Positioned.fill(
                child: IgnorePointer(
                  child: HazardStripes(
                    stripeColor: Colors.black,
                    gapColor: Colors.transparent,
                    opacity: 0.10,
                  ),
                ),
              ),
            ],
          ),
        );
    }
    // Feedback tactil adicional al de Material: leve reduccion de escala.
    final wrapped = onPressed == null ? button : PressScale(child: button);
    return expand ? SizedBox(width: double.infinity, child: wrapped) : wrapped;
  }

  Widget _filled(Color background, Color foreground) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        minimumSize: const Size(double.infinity, 64),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    );
  }
}
