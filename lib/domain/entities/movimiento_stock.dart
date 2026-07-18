import 'enums.dart';

class MovimientoStock {
  final String id;
  final String repuestoId;
  final TipoMovimientoStock tipoMovimiento;
  final double cantidad;
  final String? ordenTrabajoId;
  final String? motivo;
  final DateTime fechaCreacion;

  const MovimientoStock({
    required this.id,
    required this.repuestoId,
    required this.tipoMovimiento,
    required this.cantidad,
    this.ordenTrabajoId,
    this.motivo,
    required this.fechaCreacion,
  });
}
