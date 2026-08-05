import 'enums.dart';

class HistorialOt {
  final String id;
  final String ordenTrabajoId;
  final EventoHistorialOt evento;
  final String descripcion;
  final String? estadoAnterior;
  final String? estadoNuevo;
  final String? novedadId;
  final DateTime fechaEvento;

  const HistorialOt({
    required this.id,
    required this.ordenTrabajoId,
    required this.evento,
    required this.descripcion,
    this.estadoAnterior,
    this.estadoNuevo,
    this.novedadId,
    required this.fechaEvento,
  });
}
