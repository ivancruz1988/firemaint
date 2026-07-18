import 'package:flutter/material.dart';

import '../../../core/theme/widgets/proximamente_screen.dart';

class NovedadesStubScreen extends StatelessWidget {
  const NovedadesStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProximamenteScreen(titulo: 'Novedades', icono: Icons.report_problem_outlined);
  }
}
