import '../../../domain/entities/enums.dart';
import '../../../domain/entities/orden_trabajo.dart';

/// Criterios de busqueda del historial de ordenes de trabajo.
///
/// El filtrado se hace en memoria y no en la base: el volumen de un cuartel
/// es de cientos de ordenes, la respuesta es inmediata y, sobre todo, permite
/// que la exportacion baje exactamente lo que la pantalla esta mostrando.
class OrdenTrabajoFiltro {
  const OrdenTrabajoFiltro({
    this.texto = '',
    this.estado,
    this.prioridad,
    this.tecnicoId,
    this.sinTecnico = false,
    this.vehiculoId,
    this.anio,
    this.mes,
  });

  /// Busca en numero de OT, titulo, descripcion y observaciones.
  final String texto;
  final EstadoOt? estado;
  final PrioridadOt? prioridad;
  final String? tecnicoId;

  /// Alternativa a tecnicoId para pedir explicitamente las no asignadas, que
  /// es justo el listado que sirve para repartir trabajo.
  final bool sinTecnico;

  final String? vehiculoId;

  /// Anio y mes se evaluan sobre la fecha de creacion de la orden.
  final int? anio;
  final int? mes;

  bool get hayAlguno =>
      texto.isNotEmpty ||
      estado != null ||
      prioridad != null ||
      tecnicoId != null ||
      sinTecnico ||
      vehiculoId != null ||
      anio != null ||
      mes != null;

  bool aplica(OrdenTrabajo ot) {
    if (estado != null && ot.estado != estado) return false;
    if (prioridad != null && ot.prioridad != prioridad) return false;
    if (vehiculoId != null && ot.vehiculoId != vehiculoId) return false;
    if (sinTecnico && ot.tecnicoAsignadoId != null) return false;
    if (tecnicoId != null && ot.tecnicoAsignadoId != tecnicoId) return false;
    if (anio != null && ot.fechaCreacion.year != anio) return false;
    if (mes != null && ot.fechaCreacion.month != mes) return false;

    if (texto.isNotEmpty) {
      final q = texto.toLowerCase();
      final coincide =
          '${ot.numeroOt}'.contains(q) ||
          ot.titulo.toLowerCase().contains(q) ||
          (ot.descripcion ?? '').toLowerCase().contains(q) ||
          (ot.observaciones ?? '').toLowerCase().contains(q);
      if (!coincide) return false;
    }
    return true;
  }
}

const mesesDelAnio = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];
