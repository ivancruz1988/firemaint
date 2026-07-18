import 'package:flutter/material.dart';

import '../../../core/theme/widgets/proximamente_screen.dart';

class MantenimientoStubScreen extends StatelessWidget {
  const MantenimientoStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProximamenteScreen(
      titulo: 'Mantenimiento preventivo',
      icono: Icons.event_repeat_outlined,
    );
  }
}
