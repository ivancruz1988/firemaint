import 'dart:typed_data';

import '../entities/archivo.dart';
import '../entities/enums.dart';
import '../entities/padre_archivo.dart';

/// Adjuntos de cualquier modulo: la tabla `archivos` es polimorfica y guarda
/// fotos y documentos tanto de vehiculos como de novedades.
abstract class ArchivoRepository {
  Future<List<Archivo>> getByPadre(PadreArchivo padre);

  Future<Archivo> subir({
    required PadreArchivo padre,
    required Uint8List bytes,
    required String nombreOriginal,
    required TipoArchivo tipoArchivo,
    String? mimeType,
  });

  /// URL firmada de corta duracion para leer un archivo del bucket privado.
  Future<String> signedUrl(String storagePath);

  Future<void> eliminar(Archivo archivo);
}
