import 'package:flutter_test/flutter_test.dart';

import 'package:firemaint/domain/entities/enums.dart';
import 'package:firemaint/domain/entities/mantenimiento_programado.dart';
import 'package:firemaint/features/mantenimiento_preventivo/application/mantenimiento_providers.dart';

MantenimientoProgramado _plan({DateTime? proximaFecha, bool activo = true}) {
  return MantenimientoProgramado(
    id: 'plan-1',
    vehiculoId: 'veh-1',
    nombre: 'Cambio de aceite',
    frecuencia: Frecuencia.mensual,
    proximaFecha: proximaFecha ?? DateTime.now(),
    activo: activo,
  );
}

void main() {
  group('estaVencido', () {
    test('una fecha pasada esta vencida', () {
      final ayer = DateTime.now().subtract(const Duration(days: 1));
      expect(estaVencido(_plan(proximaFecha: ayer)), isTrue);
    });

    test('una fecha futura no esta vencida', () {
      final manana = DateTime.now().add(const Duration(days: 1));
      expect(estaVencido(_plan(proximaFecha: manana)), isFalse);
    });

    test('la fecha de hoy cuenta como vencida (vence hoy)', () {
      // proximaFecha llega de la base como medianoche del dia programado;
      // "ahora" siempre es mas tarde en el dia salvo el instante exacto de
      // medianoche, asi que un plan que vence hoy ya debe avisar.
      final medianocheDeHoy = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      expect(estaVencido(_plan(proximaFecha: medianocheDeHoy)), isTrue);
    });

    test('un plan inactivo nunca esta vencido, aunque la fecha haya pasado', () {
      final haceMuchoTiempo = DateTime(2020, 1, 1);
      expect(estaVencido(_plan(proximaFecha: haceMuchoTiempo, activo: false)), isFalse);
    });
  });
}
