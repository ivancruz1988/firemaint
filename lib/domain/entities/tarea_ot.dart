class TareaOt {
  final String id;
  final String ordenTrabajoId;
  final String descripcion;
  final bool completada;
  final int orden;

  const TareaOt({
    required this.id,
    required this.ordenTrabajoId,
    required this.descripcion,
    this.completada = false,
    this.orden = 0,
  });
}
