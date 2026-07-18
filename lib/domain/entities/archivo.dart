import 'enums.dart';

class Archivo {
  final String id;
  final String? vehiculoId;
  final String? ordenTrabajoId;
  final String? novedadId;
  final String? checklistItemId;
  final TipoArchivo tipoArchivo;
  final String storagePath;
  final String? nombreOriginal;
  final String? mimeType;
  final int? tamanoBytes;
  final DateTime fechaCreacion;

  const Archivo({
    required this.id,
    this.vehiculoId,
    this.ordenTrabajoId,
    this.novedadId,
    this.checklistItemId,
    required this.tipoArchivo,
    required this.storagePath,
    this.nombreOriginal,
    this.mimeType,
    this.tamanoBytes,
    required this.fechaCreacion,
  });
}
