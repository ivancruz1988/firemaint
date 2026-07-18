class Repuesto {
  final String id;
  final String codigo;
  final String descripcion;
  final double stock;
  final double stockMinimo;
  final String? ubicacion;
  final String unidadMedida;
  final double? costoUnitario;
  final bool activo;

  const Repuesto({
    required this.id,
    required this.codigo,
    required this.descripcion,
    this.stock = 0,
    this.stockMinimo = 0,
    this.ubicacion,
    this.unidadMedida = 'unidad',
    this.costoUnitario,
    this.activo = true,
  });

  bool get stockBajo => stock <= stockMinimo;

  Repuesto copyWith({
    String? codigo,
    String? descripcion,
    double? stock,
    double? stockMinimo,
    String? ubicacion,
    String? unidadMedida,
    double? costoUnitario,
    bool? activo,
  }) {
    return Repuesto(
      id: id,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      stock: stock ?? this.stock,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      ubicacion: ubicacion ?? this.ubicacion,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      costoUnitario: costoUnitario ?? this.costoUnitario,
      activo: activo ?? this.activo,
    );
  }
}
