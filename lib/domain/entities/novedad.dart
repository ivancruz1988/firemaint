import 'enums.dart';

class Novedad {
  final String id;
  final String vehiculoId;
  final TipoNovedad tipo;
  final String titulo;
  final String? descripcion;
  final DateTime fechaOcurrencia;
  final EstadoNovedad estado;
  final String? ordenTrabajoId;
  final String? reportadoPor;

  const Novedad({
    required this.id,
    required this.vehiculoId,
    required this.tipo,
    required this.titulo,
    this.descripcion,
    required this.fechaOcurrencia,
    this.estado = EstadoNovedad.abierta,
    this.ordenTrabajoId,
    this.reportadoPor,
  });

  Novedad copyWith({
    TipoNovedad? tipo,
    String? titulo,
    String? descripcion,
    DateTime? fechaOcurrencia,
    EstadoNovedad? estado,
    String? ordenTrabajoId,
  }) {
    return Novedad(
      id: id,
      vehiculoId: vehiculoId,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaOcurrencia: fechaOcurrencia ?? this.fechaOcurrencia,
      estado: estado ?? this.estado,
      ordenTrabajoId: ordenTrabajoId ?? this.ordenTrabajoId,
      reportadoPor: reportadoPor,
    );
  }
}
