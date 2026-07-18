import 'enums.dart';

class ChecklistItem {
  final String id;
  final String checklistId;
  final String? ordenTrabajoId;
  final String? categoria;
  final String descripcion;
  final int orden;
  final ResultadoChecklistItem? resultado;
  final String? observacion;

  const ChecklistItem({
    required this.id,
    required this.checklistId,
    this.ordenTrabajoId,
    this.categoria,
    required this.descripcion,
    this.orden = 0,
    this.resultado,
    this.observacion,
  });

  ChecklistItem copyWith({
    String? categoria,
    String? descripcion,
    int? orden,
    ResultadoChecklistItem? resultado,
    String? observacion,
    bool limpiarResultado = false,
  }) {
    return ChecklistItem(
      id: id,
      checklistId: checklistId,
      ordenTrabajoId: ordenTrabajoId,
      categoria: categoria ?? this.categoria,
      descripcion: descripcion ?? this.descripcion,
      orden: orden ?? this.orden,
      resultado: limpiarResultado ? null : (resultado ?? this.resultado),
      observacion: limpiarResultado ? null : (observacion ?? this.observacion),
    );
  }
}
