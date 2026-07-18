class Checklist {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? tipoVehiculo;
  final bool activo;

  const Checklist({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.tipoVehiculo,
    this.activo = true,
  });
}
