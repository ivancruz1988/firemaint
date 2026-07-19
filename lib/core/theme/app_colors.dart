import 'package:flutter/material.dart';

/// Paleta institucional inspirada en el mundo bomberil, en version oscura.
///
/// El rojo de marca se mantiene en la barra superior y en las acciones
/// principales; el resto de la interfaz usa neutros oscuros para reducir el
/// cansancio visual en el taller y en uso nocturno.
class AppColors {
  AppColors._();

  static const rojoBombero = Color(0xFFC62828);
  static const rojoOscuro = Color(0xFF9E1B1B); // gradientes / estados presionados

  /// Sobre fondo oscuro el rojo institucional queda por debajo del contraste
  /// minimo legible, asi que texto, iconos y bordes de foco usan esta variante.
  static const rojoClaro = Color(0xFFEF5350);

  static const amarilloSeguridad = Color(0xFFF9A825);
  static const blanco = Color(0xFFFFFFFF);

  // Neutros de fondo, superficie y bordes: dan profundidad y jerarquia visual.
  static const fondo = Color(0xFF121417); // fondo de pantallas
  static const superficie = Color(0xFF1B1F24); // tarjetas y campos
  static const relleno = Color(0xFF262B31); // rellenos suaves (chips, inputs)
  static const borde = Color(0xFF2F363E); // lineas finas / bordes de tarjeta
  static const textoPrincipal = Color(0xFFE8EBED); // texto y titulos
  static const textoTenue = Color(0xFF98A2AC); // texto secundario / labels

  // Semanticos, usados en indicadores de estado (vehiculos, OT, stock).
  // Aclarados respecto de la version clara para que contrasten contra el fondo.
  static const exito = Color(0xFF66BB6A); // operativo / finalizada
  static const alerta = Color(0xFFFFB74D); // en mantenimiento / pendiente / stock bajo
  static const critico = Color(0xFFEF5350); // fuera de servicio / prioridad critica
  static const info = Color(0xFF42A5F5); // en proceso
}
