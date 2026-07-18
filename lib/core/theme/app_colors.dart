import 'package:flutter/material.dart';

/// Paleta institucional inspirada en el mundo bomberil.
class AppColors {
  AppColors._();

  static const rojoBombero = Color(0xFFC62828);
  static const rojoOscuro = Color(0xFF9E1B1B); // para gradientes / estados presionados
  static const amarilloSeguridad = Color(0xFFF9A825);
  static const grisOscuro = Color(0xFF263238);
  static const blanco = Color(0xFFFFFFFF);

  // Neutros de fondo, superficie y bordes: dan profundidad y jerarquia visual.
  static const fondo = Color(0xFFF4F5F7); // fondo de pantallas
  static const superficie = Color(0xFFFFFFFF); // tarjetas y campos
  static const grisClaro = Color(0xFFEEF1F4); // rellenos suaves (chips, inputs)
  static const borde = Color(0xFFE3E6EA); // lineas finas / bordes de tarjeta
  static const textoTenue = Color(0xFF6B7780); // texto secundario / labels

  // Semanticos, usados en indicadores de estado (vehiculos, OT, stock).
  static const exito = Color(0xFF2E7D32); // operativo / finalizada
  static const alerta = Color(0xFFF57F17); // en mantenimiento / pendiente / stock bajo
  static const critico = Color(0xFFB71C1C); // fuera de servicio / prioridad critica
  static const info = Color(0xFF1565C0); // en proceso
}
