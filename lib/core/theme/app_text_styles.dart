import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografia grande y de alto contraste, pensada para leerse en taller
/// (pantallas con guantes puestos, luz variable).
///
/// La familia Archivo Narrow se aplica de forma global vía
/// [AppTheme.dark]'s `textTheme`, asi que estos estilos no la repiten: la
/// heredan del `DefaultTextStyle` ambiente. La unica excepcion es
/// [kpiNumber], que usa JetBrains Mono (datos tabulares) y por eso necesita
/// su propia llamada a GoogleFonts.
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
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textoPrincipal,
    height: 1.5,
  );

  /// Para headers de formulario y descriptores de metadata: se usa en
  /// mayusculas (aplicar `.toUpperCase()` al texto en el punto de uso).
  static const label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textoTenue,
    letterSpacing: 1.4,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textoTenue,
  );

  /// VIN, odometro, presion, numeros de OT y KPIs: monoespaciada para
  /// alineacion vertical y legibilidad de cifras criticas.
  static final kpiNumber = GoogleFonts.jetBrainsMono(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: AppColors.textoPrincipal,
    letterSpacing: -1,
    height: 1,
  );
}
