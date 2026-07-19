import 'package:flutter_test/flutter_test.dart';

import 'package:firemaint/domain/entities/padre_archivo.dart';

void main() {
  group('PadreArchivo', () {
    // Se usa como argumento de un FutureProvider.family: si equals/hashCode
    // estuvieran mal, Riverpod trataria cada instancia como una clave
    // distinta y nunca compartiria cache entre rebuilds del mismo widget.
    test('dos instancias con el mismo tipo e id son iguales entre si', () {
      const a = PadreArchivo.vehiculo('abc');
      const b = PadreArchivo.vehiculo('abc');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('mismo id pero distinto tipo no son iguales', () {
      const vehiculo = PadreArchivo.vehiculo('abc');
      const novedad = PadreArchivo.novedad('abc');
      expect(vehiculo, isNot(equals(novedad)));
    });

    test('distinto id no son iguales', () {
      const a = PadreArchivo.vehiculo('abc');
      const b = PadreArchivo.vehiculo('xyz');
      expect(a, isNot(equals(b)));
    });

    test('la carpeta de storage separa vehiculos de novedades', () {
      expect(const PadreArchivo.vehiculo('abc').carpetaStorage, 'vehiculos/abc');
      expect(const PadreArchivo.novedad('abc').carpetaStorage, 'novedades/abc');
    });
  });
}
