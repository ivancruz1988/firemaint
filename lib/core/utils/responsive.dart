import 'package:flutter/widgets.dart';

/// Punto de quiebre entre layout de celular (nav inferior) y de escritorio/PWA
/// en pantalla ancha (nav lateral).
const double kDesktopBreakpoint = 600;

extension ResponsiveContext on BuildContext {
  bool get isDesktop => MediaQuery.sizeOf(this).width >= kDesktopBreakpoint;
}
