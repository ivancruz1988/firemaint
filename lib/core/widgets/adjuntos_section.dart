import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/repository_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/widgets/fire_card.dart';
import '../../domain/entities/archivo.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/padre_archivo.dart';
import '../providers/archivos_providers.dart';

class AdjuntosSection extends ConsumerStatefulWidget {
  const AdjuntosSection({super.key, required this.padre});

  final PadreArchivo padre;

  @override
  ConsumerState<AdjuntosSection> createState() => _AdjuntosSectionState();
}

class _AdjuntosSectionState extends ConsumerState<AdjuntosSection> {
  bool _subiendo = false;

  Future<void> _subirFoto() async {
    final picker = ImagePicker();
    final foto = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (foto == null) return;
    await _subir(await foto.readAsBytes(), foto.name, TipoArchivo.foto, foto.mimeType);
  }

  Future<void> _subirDocumento() async {
    final resultado = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    final archivo = resultado?.files.single;
    if (archivo?.bytes == null) return;
    await _subir(archivo!.bytes!, archivo.name, TipoArchivo.documento, null);
  }

  Future<void> _subir(Uint8List bytes, String nombre, TipoArchivo tipo, String? mimeType) async {
    setState(() => _subiendo = true);
    try {
      await ref
          .read(archivoRepositoryProvider)
          .subir(
            padre: widget.padre,
            bytes: bytes,
            nombreOriginal: nombre,
            tipoArchivo: tipo,
            mimeType: mimeType,
          );
      ref.invalidate(archivosDePadreProvider(widget.padre));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo subir el archivo: $e')));
      }
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
  }

  Future<void> _eliminar(Archivo archivo) async {
    await ref.read(archivoRepositoryProvider).eliminar(archivo);
    ref.invalidate(archivosDePadreProvider(widget.padre));
  }

  @override
  Widget build(BuildContext context) {
    final archivosAsync = ref.watch(archivosDePadreProvider(widget.padre));

    return FireCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_file, color: AppColors.textoPrincipal),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Fotos, manuales y documentacion', style: AppTextStyles.title),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _subiendo ? null : _subirFoto,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text('Foto'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _subiendo ? null : _subirDocumento,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Documento'),
                ),
              ),
            ],
          ),
          if (_subiendo)
            const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
          const SizedBox(height: 12),
          archivosAsync.when(
            data: (archivos) {
              if (archivos.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Todavia no hay adjuntos.', style: AppTextStyles.label),
                );
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: archivos
                    .map((a) => _ArchivoTile(archivo: a, onDelete: () => _eliminar(a)))
                    .toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Text('No se pudieron cargar los adjuntos: $error'),
          ),
        ],
      ),
    );
  }
}

class _ArchivoTile extends ConsumerWidget {
  const _ArchivoTile({required this.archivo, required this.onDelete});

  final Archivo archivo;
  final VoidCallback onDelete;

  bool get _esImagen =>
      archivo.tipoArchivo == TipoArchivo.foto ||
      archivo.tipoArchivo == TipoArchivo.fotoAntes ||
      archivo.tipoArchivo == TipoArchivo.fotoDespues;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: ref.read(archivoRepositoryProvider).signedUrl(archivo.storagePath),
      builder: (context, snapshot) {
        final url = snapshot.data;
        return Stack(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: (_esImagen && url != null)
                  ? CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => const Icon(Icons.broken_image_outlined),
                    )
                  : Center(
                      child: Icon(
                        _esImagen ? Icons.image_outlined : Icons.insert_drive_file_outlined,
                        color: AppColors.textoPrincipal,
                      ),
                    ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: onDelete,
                child: const CircleAvatar(
                  radius: 11,
                  backgroundColor: AppColors.critico,
                  child: Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
