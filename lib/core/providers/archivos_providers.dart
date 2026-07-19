import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/archivo.dart';
import '../../domain/entities/padre_archivo.dart';
import 'repository_providers.dart';

/// Adjuntos de un vehiculo o de una novedad, segun el padre que se pase.
final archivosDePadreProvider = FutureProvider.family<List<Archivo>, PadreArchivo>((ref, padre) {
  return ref.watch(archivoRepositoryProvider).getByPadre(padre);
});
