import 'package:flutter/material.dart';

import '../../../core/theme/widgets/proximamente_screen.dart';

class ChecklistsStubScreen extends StatelessWidget {
  const ChecklistsStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProximamenteScreen(titulo: 'Checklists', icono: Icons.fact_check_outlined);
  }
}
