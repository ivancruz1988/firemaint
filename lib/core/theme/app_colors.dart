import 'package:flutter/material.dart';

/// Paleta institucional inspirada en el mundo bomberil, en version oscura.
///
/// Alineada al sistema de diseno "Operaciones de Flota" (spec Stitch): estetica
/// de sala de control tactica para taller nocturno. El rojo de marca se
/// mantiene en la barra superior y en las acciones principales; el resto de
/// la interfaz usa neutros oscuros para reducir el cansancio visual.
class AppColors {
  AppColors._();

  static const rojoBombero = Color(0xFFE63329); // Fire Engine Red
  static const rojoOscuro = Color(0xFFAC261F); // gradientes / estados presionados

  /// Sobre fondo oscuro el rojo institucional queda por debajo del contraste
  /// minimo legible, asi que texto y iconos de acento usan esta variante. El
  /// foco de inputs usa amarilloSeguridad (ver AppTheme), no esta.
  static const rojoClaro = Color(0xFFFFB4A9);

  static const amarilloSeguridad = Color(0xFFFFB800); // Reflective Amber
  static const blanco = Color(0xFFFFFFFF);

  // Neutros de fondo, superficie y bordes: dan profundidad y jerarquia visual
  // por capas tonales en vez de sombras.
  static const fondo = Color(0xFF0D0D0F); // fondo de pantallas (Level 0)
  static const superficie = Color(0xFF1A1C20); // tarjetas y campos (Level 1)
  static const relleno = Color(0xFF333539); // rellenos solidos (chips)
  static const borde = Color(0xFF2D2F36); // lineas finas / bordes de tarjeta
  static const textoPrincipal = Color(0xFFE2E2E7); // texto y titulos
  static const textoTenue = Color(0xFF98A2AC); // texto secundario / labels

  // Semanticos, usados en indicadores de estado (vehiculos, OT, stock).
  // Aclarados respecto de la version clara para que contrasten contra el fondo.
  static const exito = Color(0xFF4AE183); // operativo / finalizada
  static const alerta = Color(0xFFFFB74D); // en mantenimiento / pendiente / stock bajo
  static const critico = Color(0xFFFFB4AB); // fuera de servicio / prioridad critica
  static const info = Color(0xFF42A5F5); // en proceso
}
