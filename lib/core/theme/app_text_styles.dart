import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tipografia grande y de alto contraste, pensada para leerse en taller
/// (pantallas con guantes puestos, luz variable).
class AppTextStyles {
  AppTextStyles._();

  static const headline = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.textoPrincipal,
    letterSpacing: -0.4,
    height: 1.2,
  );

  static const title = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
    letterSpacing: -0.2,
    height: 1.25,
  );

  static const subtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textoPrincipal,
  );

  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textoPrincipal,
    height: 1.35,
  );

  static const label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textoTenue,
    letterSpacing: 0.1,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textoTenue,
  );

  static const kpiNumber = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: AppColors.textoPrincipal,
    letterSpacing: -1,
    height: 1,
  );
}
