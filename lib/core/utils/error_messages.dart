import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

/// true si el error es de conectividad (no llego a haber respuesta del
/// servidor), a diferencia de un PostgrestException/AuthException, que ya es
/// una respuesta del servidor (permiso denegado, dato invalido, etc.) y por
/// lo tanto no tiene sentido reintentar sola.
bool esErrorDeConexion(Object error) {
  return error is SocketException ||
      error is TimeoutException ||
      error is ClientException ||
      // En Flutter Web, un fetch fallido por falta de red llega como
      // Exception generica con este texto, sin un tipo mas especifico.
      error.toString().contains('Failed to fetch') ||
      error.toString().contains('Connection closed');
}

/// Mensaje en castellano para mostrar al usuario. Sin conexion se prioriza
/// que sepa que nada se perdio; con conexion, se muestra el motivo real que
/// da el servidor en lugar de un texto generico.
String mensajeDeError(Object error, {String accion = 'guardar'}) {
  if (esErrorDeConexion(error)) {
    return 'Sin conexion a internet. Los datos no se perdieron: volve a '
        'intentar cuando tengas señal.';
  }
  if (error is AuthException) return error.message;
  if (error is PostgrestException) return error.message;
  return 'No se pudo $accion: $error';
}
