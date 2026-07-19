/// Identifica a que registro pertenece un archivo adjunto.
///
/// La tabla `archivos` admite un unico padre por fila (constraint
/// chk_archivos_un_padre), por eso se modela como un tipo cerrado en lugar de
/// varios campos opcionales sueltos.
enum TipoPadreArchivo {
  vehiculo('vehiculo_id', 'vehiculos'),
  novedad('novedad_id', 'novedades');

  const TipoPadreArchivo(this.columna, this.carpeta);

  /// Columna de `archivos` que referencia a este tipo de padre.
  final String columna;

  /// Prefijo de carpeta dentro del bucket, para que no se mezclen los
  /// adjuntos de distintos modulos.
  final String carpeta;
}

class PadreArchivo {
  const PadreArchivo.vehiculo(this.id) : tipo = TipoPadreArchivo.vehiculo;
  const PadreArchivo.novedad(this.id) : tipo = TipoPadreArchivo.novedad;

  final String id;
  final TipoPadreArchivo tipo;

  /// Ruta dentro del bucket: novedades/{id}/archivo.jpg
  String get carpetaStorage => '${tipo.carpeta}/$id';

  // Necesarios porque se usa como argumento de un FutureProvider.family:
  // sin esto Riverpod crearia un provider distinto en cada rebuild.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PadreArchivo && other.id == id && other.tipo == tipo;

  @override
  int get hashCode => Object.hash(id, tipo);
}
