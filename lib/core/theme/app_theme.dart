import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      // El rojo institucional se mantiene como color de marca en AppBar y FAB,
      // donde va sobre blanco. Para acentos sobre superficies oscuras (foco de
      // inputs, item de navegacion activo) se usa rojoClaro, que si contrasta.
      primary: AppColors.rojoBombero,
      onPrimary: AppColors.blanco,
      secondary: AppColors.amarilloSeguridad,
      onSecondary: AppColors.fondo,
      error: AppColors.critico,
      onError: AppColors.fondo,
      surface: AppColors.superficie,
      onSurface: AppColors.textoPrincipal,
      surfaceContainerHighest: AppColors.relleno,
      onSurfaceVariant: AppColors.textoTenue,
      outline: AppColors.borde,
      outlineVariant: AppColors.borde,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.fondo,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.rojoBombero,
        foregroundColor: AppColors.blanco,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        titleTextStyle: TextStyle(
          color: AppColors.blanco,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          side: const BorderSide(color: AppColors.borde, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.rojoClaro),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // Relleno, no superficie: los campos van dentro de tarjetas y con el
        // mismo tono se perderia el limite entre uno y otro.
        fillColor: AppColors.relleno,
        labelStyle: const TextStyle(color: AppColors.textoTenue, fontWeight: FontWeight.w500),
        floatingLabelStyle: const TextStyle(
          color: AppColors.rojoClaro,
          fontWeight: FontWeight.w700,
        ),
        prefixIconColor: AppColors.textoTenue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.rojoClaro, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.critico),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: AppColors.superficie,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        // En oscuro la sombra casi no se percibe: la separacion entre tarjeta
        // y fondo la da el borde, no la elevacion.
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borde),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.relleno,
        selectedColor: AppColors.rojoClaro.withValues(alpha: 0.22),
        side: BorderSide.none,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textoPrincipal),
        secondaryLabelStyle: const TextStyle(color: AppColors.rojoClaro),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.borde, thickness: 1, space: 24),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.rojoBombero,
        foregroundColor: AppColors.blanco,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.relleno,
        contentTextStyle: const TextStyle(
          color: AppColors.textoPrincipal,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.textoTenue),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.superficie,
        indicatorColor: AppColors.rojoClaro.withValues(alpha: 0.20),
        elevation: 3,
        height: 70,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.rojoClaro : AppColors.textoTenue,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? AppColors.rojoClaro : AppColors.textoTenue);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.superficie,
        indicatorColor: AppColors.rojoClaro.withValues(alpha: 0.20),
        selectedIconTheme: const IconThemeData(color: AppColors.rojoClaro),
        unselectedIconTheme: const IconThemeData(color: AppColors.textoTenue),
        selectedLabelTextStyle: const TextStyle(
          color: AppColors.rojoClaro,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: AppColors.textoTenue,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}
