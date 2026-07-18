import 'package:flutter/material.dart';

import '../../../core/theme/widgets/proximamente_screen.dart';

class RepuestosStubScreen extends StatelessWidget {
  const RepuestosStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProximamenteScreen(titulo: 'Repuestos', icono: Icons.settings_suggest_outlined);
  }
}
