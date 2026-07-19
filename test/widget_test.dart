import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firemaint/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('LoginScreen muestra el formulario de inicio de sesion', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: LoginScreen())));
    // El login usa FadeSlideIn con animaciones escalonadas via Future.delayed;
    // sin dejarlas terminar, el test framework falla por timers pendientes.
    await tester.pumpAndSettle();

    expect(find.text('Sistema de Gestion de Automotores'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
  });
}
