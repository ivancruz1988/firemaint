import 'enums.dart';

class HistorialEvento {
  final String id;
  final String vehiculoId;
  final TipoEventoHistorial tipoEvento;
  final String? ordenTrabajoId;
  final String? novedadId;
  final String? mantenimientoProgramadoId;
  final String descripcion;
  final DateTime fechaEvento;

  const HistorialEvento({
    required this.id,
    required this.vehiculoId,
    required this.tipoEvento,
    this.ordenTrabajoId,
    this.novedadId,
    this.mantenimientoProgramadoId,
    required this.descripcion,
    required this.fechaEvento,
  });
}
