import 'package:flutter/material.dart';

/// Anillo de urgencia para alertas criticas (mantenimiento vencido, vehiculo
/// fuera de servicio, OT critica). Pulso lento y continuo: transmite
/// urgencia real sin parpadeo agresivo tipo sirena.
class PulseGlow extends StatefulWidget {
  const PulseGlow({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.period = const Duration(milliseconds: 1600),
  });

  final Widget child;
  final Color color;
  final BorderRadius borderRadius;
  final Duration period;

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.45 * t),
                blurRadius: 4 + 10 * t,
                spreadRadius: 1 + 3 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
