import 'dart:typed_data';

import '../entities/archivo.dart';
import '../entities/enums.dart';

abstract class VehiculoArchivoRepository {
  Future<List<Archivo>> getByVehiculo(String vehiculoId);

  Future<Archivo> subir({
    required String vehiculoId,
    required Uint8List bytes,
    required String nombreOriginal,
    required TipoArchivo tipoArchivo,
    String? mimeType,
  });

  /// URL firmada de corta duracion para leer un archivo del bucket privado.
  Future<String> signedUrl(String storagePath);

  Future<void> eliminar(Archivo archivo);
}
