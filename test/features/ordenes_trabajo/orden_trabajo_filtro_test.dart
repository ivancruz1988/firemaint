import 'package:flutter_test/flutter_test.dart';

import 'package:firemaint/domain/entities/enums.dart';
import 'package:firemaint/domain/entities/orden_trabajo.dart';
import 'package:firemaint/features/ordenes_trabajo/application/orden_trabajo_filtro.dart';

OrdenTrabajo _ot({
  int numeroOt = 1,
  String vehiculoId = 'veh-1',
  String titulo = 'Cambio de aceite',
  String? descripcion,
  String? observaciones,
  PrioridadOt prioridad = PrioridadOt.media,
  EstadoOt estado = EstadoOt.pendiente,
  String? tecnicoAsignadoId,
  DateTime? fechaCreacion,
}) {
  return OrdenTrabajo(
    id: 'ot-$numeroOt',
    numeroOt: numeroOt,
    vehiculoId: vehiculoId,
    titulo: titulo,
    descripcion: descripcion,
    observaciones: observaciones,
    prioridad: prioridad,
    estado: estado,
    tecnicoAsignadoId: tecnicoAsignadoId,
    fechaCreacion: fechaCreacion ?? DateTime(2026, 3, 15),
  );
}

void main() {
  group('OrdenTrabajoFiltro.aplica', () {
    test('sin filtros aplicados, todo pasa', () {
      const filtro = OrdenTrabajoFiltro();
      expect(filtro.hayAlguno, isFalse);
      expect(filtro.aplica(_ot()), isTrue);
    });

    test('el texto busca en numero de OT', () {
      const filtro = OrdenTrabajoFiltro(texto: '42');
      expect(filtro.aplica(_ot(numeroOt: 42)), isTrue);
      expect(filtro.aplica(_ot(numeroOt: 7)), isFalse);
    });

    test('el texto busca en titulo sin importar mayusculas', () {
      const filtro = OrdenTrabajoFiltro(texto: 'FRENOS');
      expect(filtro.aplica(_ot(titulo: 'Revision de frenos')), isTrue);
      expect(filtro.aplica(_ot(titulo: 'Cambio de aceite')), isFalse);
    });

    test('el texto tambien busca en descripcion y observaciones', () {
      const filtroDescripcion = OrdenTrabajoFiltro(texto: 'ruido extrano');
      expect(
        filtroDescripcion.aplica(_ot(descripcion: 'Se escucha un ruido extrano al frenar')),
        isTrue,
      );

      const filtroObservaciones = OrdenTrabajoFiltro(texto: 'pendiente repuesto');
      expect(
        filtroObservaciones.aplica(_ot(observaciones: 'Queda pendiente repuesto importado')),
        isTrue,
      );
    });

    test('filtra por estado exacto', () {
      const filtro = OrdenTrabajoFiltro(estado: EstadoOt.finalizada);
      expect(filtro.aplica(_ot(estado: EstadoOt.finalizada)), isTrue);
      expect(filtro.aplica(_ot(estado: EstadoOt.pendiente)), isFalse);
    });

    test('filtra por prioridad exacta', () {
      const filtro = OrdenTrabajoFiltro(prioridad: PrioridadOt.critica);
      expect(filtro.aplica(_ot(prioridad: PrioridadOt.critica)), isTrue);
      expect(filtro.aplica(_ot(prioridad: PrioridadOt.baja)), isFalse);
    });

    test('filtra por vehiculo', () {
      const filtro = OrdenTrabajoFiltro(vehiculoId: 'veh-9');
      expect(filtro.aplica(_ot(vehiculoId: 'veh-9')), isTrue);
      expect(filtro.aplica(_ot(vehiculoId: 'veh-1')), isFalse);
    });

    test('sinTecnico solo deja pasar las que no tienen tecnico asignado', () {
      const filtro = OrdenTrabajoFiltro(sinTecnico: true);
      expect(filtro.aplica(_ot(tecnicoAsignadoId: null)), isTrue);
      expect(filtro.aplica(_ot(tecnicoAsignadoId: 'user-1')), isFalse);
    });

    test('tecnicoId filtra por el tecnico exacto', () {
      const filtro = OrdenTrabajoFiltro(tecnicoId: 'user-1');
      expect(filtro.aplica(_ot(tecnicoAsignadoId: 'user-1')), isTrue);
      expect(filtro.aplica(_ot(tecnicoAsignadoId: 'user-2')), isFalse);
      expect(filtro.aplica(_ot(tecnicoAsignadoId: null)), isFalse);
    });

    test('filtra por anio y mes de la fecha de creacion', () {
      const filtro = OrdenTrabajoFiltro(anio: 2026, mes: 3);
      expect(filtro.aplica(_ot(fechaCreacion: DateTime(2026, 3, 15))), isTrue);
      expect(filtro.aplica(_ot(fechaCreacion: DateTime(2026, 4, 15))), isFalse);
      expect(filtro.aplica(_ot(fechaCreacion: DateTime(2025, 3, 15))), isFalse);
    });

    test('combina varios criterios a la vez (AND, no OR)', () {
      const filtro = OrdenTrabajoFiltro(
        estado: EstadoOt.enProceso,
        prioridad: PrioridadOt.alta,
        vehiculoId: 'veh-5',
      );
      final coincide = _ot(
        estado: EstadoOt.enProceso,
        prioridad: PrioridadOt.alta,
        vehiculoId: 'veh-5',
      );
      final coincideParcial = _ot(
        estado: EstadoOt.enProceso,
        prioridad: PrioridadOt.baja,
        vehiculoId: 'veh-5',
      );

      expect(filtro.aplica(coincide), isTrue);
      expect(filtro.aplica(coincideParcial), isFalse);
    });
  });
}
