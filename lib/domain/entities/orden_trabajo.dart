import 'enums.dart';

class OrdenTrabajo {
  final String id;
  final int numeroOt;
  final String vehiculoId;
  final String titulo;
  final String? descripcion;
  final PrioridadOt prioridad;
  final EstadoOt estado;
  final String? tecnicoAsignadoId;
  final double? horasTrabajo;
  final double? costoEstimado;
  final double? costoReal;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String? observaciones;
  final DateTime fechaCreacion;

  const OrdenTrabajo({
    required this.id,
    required this.numeroOt,
    required this.vehiculoId,
    required this.titulo,
    this.descripcion,
    this.prioridad = PrioridadOt.media,
    this.estado = EstadoOt.pendiente,
    this.tecnicoAsignadoId,
    this.horasTrabajo,
    this.costoEstimado,
    this.costoReal,
    this.fechaInicio,
    this.fechaFin,
    this.observaciones,
    required this.fechaCreacion,
  });

  OrdenTrabajo copyWith({
    String? titulo,
    String? descripcion,
    PrioridadOt? prioridad,
    EstadoOt? estado,
    String? tecnicoAsignadoId,
    double? horasTrabajo,
    double? costoEstimado,
    double? costoReal,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? observaciones,
  }) {
    return OrdenTrabajo(
      id: id,
      numeroOt: numeroOt,
      vehiculoId: vehiculoId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      prioridad: prioridad ?? this.prioridad,
      estado: estado ?? this.estado,
      tecnicoAsignadoId: tecnicoAsignadoId ?? this.tecnicoAsignadoId,
      horasTrabajo: horasTrabajo ?? this.horasTrabajo,
      costoEstimado: costoEstimado ?? this.costoEstimado,
      costoReal: costoReal ?? this.costoReal,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      observaciones: observaciones ?? this.observaciones,
      fechaCreacion: fechaCreacion,
    );
  }
}
