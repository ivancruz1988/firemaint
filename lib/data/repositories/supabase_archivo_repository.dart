import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/archivo.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/padre_archivo.dart';
import '../../domain/repositories/archivo_repository.dart';

/// El bucket conserva el nombre original de cuando solo guardaba adjuntos de
/// vehiculos. Renombrarlo obligaria a migrar los archivos ya subidos, asi que
/// se separan por carpeta en lugar de por bucket.
const _bucket = 'vehiculo-adjuntos';
const _uuid = Uuid();

class SupabaseArchivoRepository implements ArchivoRepository {
  SupabaseArchivoRepository(this._client);

  final SupabaseClient _client;

  Archivo _fromMap(Map<String, dynamic> map) {
    return Archivo(
      id: map['id'] as String,
      vehiculoId: map['vehiculo_id'] as String?,
      ordenTrabajoId: map['orden_trabajo_id'] as String?,
      novedadId: map['novedad_id'] as String?,
      checklistItemId: map['checklist_item_id'] as String?,
      tipoArchivo: TipoArchivo.fromDb(map['tipo_archivo'] as String),
      storagePath: map['storage_path'] as String,
      nombreOriginal: map['nombre_original'] as String?,
      mimeType: map['mime_type'] as String?,
      tamanoBytes: map['tamano_bytes'] as int?,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
    );
  }

  @override
  Future<List<Archivo>> getByPadre(PadreArchivo padre) async {
    final rows = await _client
        .from('archivos')
        .select()
        .eq(padre.tipo.columna, padre.id)
        .order('fecha_creacion', ascending: false);
    return rows.map(_fromMap).toList();
  }

  @override
  Future<Archivo> subir({
    required PadreArchivo padre,
    required Uint8List bytes,
    required String nombreOriginal,
    required TipoArchivo tipoArchivo,
    String? mimeType,
  }) async {
    final path = '${padre.carpetaStorage}/${_uuid.v4()}_$nombreOriginal';
    await _client.storage
        .from(_bucket)
        .uploadBinary(path, bytes, fileOptions: FileOptions(contentType: mimeType));

    final row = await _client
        .from('archivos')
        .insert({
          padre.tipo.columna: padre.id,
          'tipo_archivo': tipoArchivo.toDb(),
          'storage_path': path,
          'nombre_original': nombreOriginal,
          'mime_type': mimeType,
          'tamano_bytes': bytes.length,
        })
        .select()
        .single();
    return _fromMap(row);
  }

  @override
  Future<String> signedUrl(String storagePath) {
    return _client.storage.from(_bucket).createSignedUrl(storagePath, 3600);
  }

  @override
  Future<void> eliminar(Archivo archivo) async {
    await _client.storage.from(_bucket).remove([archivo.storagePath]);
    await _client.from('archivos').delete().eq('id', archivo.id);
  }
}
