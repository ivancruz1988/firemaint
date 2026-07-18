import 'enums.dart';

class MantenimientoProgramado {
  final String id;
  final String vehiculoId;
  final String? checklistId;
  final String nombre;
  final String? descripcion;
  final Frecuencia frecuencia;
  final DateTime proximaFecha;
  final DateTime? ultimaFechaEjecucion;
  final bool activo;

  const MantenimientoProgramado({
    required this.id,
    required this.vehiculoId,
    this.checklistId,
    required this.nombre,
    this.descripcion,
    required this.frecuencia,
    required this.proximaFecha,
    this.ultimaFechaEjecucion,
    this.activo = true,
  });
}
