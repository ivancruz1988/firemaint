import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/archivo.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/vehiculo_archivo_repository.dart';

const _bucket = 'vehiculo-adjuntos';
const _uuid = Uuid();

class SupabaseVehiculoArchivoRepository implements VehiculoArchivoRepository {
  SupabaseVehiculoArchivoRepository(this._client);

  final SupabaseClient _client;

  Archivo _fromMap(Map<String, dynamic> map) {
    return Archivo(
      id: map['id'] as String,
      vehiculoId: map['vehiculo_id'] as String?,
      tipoArchivo: TipoArchivo.fromDb(map['tipo_archivo'] as String),
      storagePath: map['storage_path'] as String,
      nombreOriginal: map['nombre_original'] as String?,
      mimeType: map['mime_type'] as String?,
      tamanoBytes: map['tamano_bytes'] as int?,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
    );
  }

  @override
  Future<List<Archivo>> getByVehiculo(String vehiculoId) async {
    final rows = await _client
        .from('archivos')
        .select()
        .eq('vehiculo_id', vehiculoId)
        .order('fecha_creacion', ascending: false);
    return rows.map(_fromMap).toList();
  }

  @override
  Future<Archivo> subir({
    required String vehiculoId,
    required Uint8List bytes,
    required String nombreOriginal,
    required TipoArchivo tipoArchivo,
    String? mimeType,
  }) async {
    final path = '$vehiculoId/${_uuid.v4()}_$nombreOriginal';
    await _client.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mimeType),
        );

    final row = await _client
        .from('archivos')
        .insert({
          'vehiculo_id': vehiculoId,
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
