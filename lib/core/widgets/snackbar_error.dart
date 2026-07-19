import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/error_messages.dart';

/// Muestra el error de una operacion fallida con un boton para reintentarla
/// sin tener que repetir lo que el usuario ya habia hecho (tipear un texto,
/// elegir una fecha, etc.).
///
/// `reintentar` recibe la funcion que hizo el intento original: si vuelve a
/// fallar, se vuelve a mostrar este mismo aviso, asi que el usuario puede
/// reintentar tantas veces como quiera hasta que vuelva la señal.
void mostrarErrorConReintento(
  BuildContext context,
  Object error,
  Future<void> Function() reintentar, {
  String accion = 'guardar',
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: AppColors.critico,
      content: Text(mensajeDeError(error, accion: accion)),
      duration: const Duration(seconds: 6),
      action: SnackBarAction(
        label: 'Reintentar',
        textColor: AppColors.blanco,
        onPressed: () => reintentar(),
      ),
    ),
  );
}
