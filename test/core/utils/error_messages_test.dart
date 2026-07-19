import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:firemaint/core/utils/error_messages.dart';

void main() {
  group('esErrorDeConexion', () {
    test('reconoce SocketException, TimeoutException y ClientException', () {
      expect(esErrorDeConexion(const SocketException('sin red')), isTrue);
      expect(esErrorDeConexion(TimeoutException('tardo demasiado')), isTrue);
      expect(esErrorDeConexion(ClientException('fetch fallo')), isTrue);
    });

    test('reconoce el texto que tira fetch en Flutter Web', () {
      expect(esErrorDeConexion(Exception('Failed to fetch')), isTrue);
    });

    test(
      'un PostgrestException no es un error de conexion: es una respuesta real del servidor',
      () {
        const error = PostgrestException(message: 'permiso denegado', code: '42501');
        expect(esErrorDeConexion(error), isFalse);
      },
    );

    test('un AuthException tampoco es un error de conexion', () {
      const error = AuthException('Invalid login credentials');
      expect(esErrorDeConexion(error), isFalse);
    });
  });

  group('mensajeDeError', () {
    test('sin conexion, el mensaje aclara que no se perdio nada', () {
      final mensaje = mensajeDeError(const SocketException('sin red'));
      expect(mensaje, contains('Sin conexion'));
      expect(mensaje, isNot(contains('SocketException')));
    });

    test('con un error del servidor, se muestra el motivo real', () {
      const error = PostgrestException(message: 'Solo un administrador puede crear usuarios');
      expect(mensajeDeError(error), 'Solo un administrador puede crear usuarios');
    });

    test('un error generico incluye la accion que se intentaba hacer', () {
      final mensaje = mensajeDeError(Exception('algo raro'), accion: 'eliminar el vehiculo');
      expect(mensaje, contains('eliminar el vehiculo'));
    });
  });
}
