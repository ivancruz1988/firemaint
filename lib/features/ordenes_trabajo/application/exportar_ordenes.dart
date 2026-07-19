import 'dart:typed_data';

import 'package:excel/excel.dart' as xls;
import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/formatters.dart';
import '../../../domain/entities/orden_trabajo.dart';
import '../../../domain/entities/usuario.dart';
import '../../../domain/entities/vehiculo.dart';

/// Exportacion del historial de ordenes de trabajo a Excel y PDF.
///
/// Las dos salidas comparten el armado de filas para que no se desincronicen:
/// si manana se agrega una columna, aparece en ambos formatos.

/// Columnas completas, tal como salen al Excel.
const _encabezados = [
  'N OT',
  'Estado',
  'Prioridad',
  'Vehiculo',
  'Titulo',
  'Descripcion',
  'Tecnico asignado',
  'Horas',
  'Costo estimado',
  'Costo real',
  'Inicio',
  'Fin',
  'Creada',
  'Observaciones',
];

/// Subconjunto que entra legible en una hoja apaisada. Las columnas de texto
/// largo se omiten en el PDF: con catorce columnas la tabla queda ilegible.
const _indicesPdf = [0, 1, 2, 3, 4, 6, 7, 9, 10, 11];

String _fecha(DateTime? d) => d == null ? '' : formatDate(d);
String _num(num? v) => v == null ? '' : formatNumber(v);

List<String> _fila(
  OrdenTrabajo ot,
  Map<String, Vehiculo> vehiculos,
  Map<String, Usuario> usuarios,
) {
  final v = vehiculos[ot.vehiculoId];
  final t = ot.tecnicoAsignadoId == null ? null : usuarios[ot.tecnicoAsignadoId];
  return [
    '${ot.numeroOt}',
    ot.estado.label,
    ot.prioridad.label,
    v == null ? '' : '${v.numeroInterno} - ${v.marca} ${v.modelo}',
    ot.titulo,
    ot.descripcion ?? '',
    t?.nombreCompleto ?? 'Sin asignar',
    _num(ot.horasTrabajo),
    _num(ot.costoEstimado),
    _num(ot.costoReal),
    _fecha(ot.fechaInicio),
    _fecha(ot.fechaFin),
    _fecha(ot.fechaCreacion),
    ot.observaciones ?? '',
  ];
}

String _nombreArchivo() {
  final ahora = DateTime.now();
  final mm = ahora.month.toString().padLeft(2, '0');
  final dd = ahora.day.toString().padLeft(2, '0');
  return 'ordenes_trabajo_${ahora.year}$mm$dd';
}

Future<void> exportarOrdenesAExcel({
  required List<OrdenTrabajo> ordenes,
  required Map<String, Vehiculo> vehiculos,
  required Map<String, Usuario> usuarios,
}) async {
  final libro = xls.Excel.createExcel();
  final hoja = libro[libro.getDefaultSheet()!];

  hoja.appendRow([for (final h in _encabezados) xls.TextCellValue(h)]);

  for (final ot in ordenes) {
    final fila = _fila(ot, vehiculos, usuarios);
    hoja.appendRow([
      // El numero de OT va como numero para que Excel lo ordene bien; el
      // resto como texto, que evita que interprete fechas y montos a su modo.
      xls.IntCellValue(ot.numeroOt),
      for (final celda in fila.skip(1)) xls.TextCellValue(celda),
    ]);
  }

  final bytes = libro.encode();
  if (bytes == null) throw Exception('No se pudo generar el archivo Excel');

  await FileSaver.instance.saveFile(
    name: _nombreArchivo(),
    bytes: Uint8List.fromList(bytes),
    fileExtension: 'xlsx',
    mimeType: MimeType.microsoftExcel,
  );
}

Future<void> exportarOrdenesAPdf({
  required List<OrdenTrabajo> ordenes,
  required Map<String, Vehiculo> vehiculos,
  required Map<String, Usuario> usuarios,
}) async {
  final doc = pw.Document();
  final encabezadosPdf = [for (final i in _indicesPdf) _encabezados[i]];
  final filas = [
    for (final ot in ordenes) [for (final i in _indicesPdf) _fila(ot, vehiculos, usuarios)[i]],
  ];

  doc.addPage(
    pw.MultiPage(
      // Apaisado: son diez columnas y en vertical no entran.
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(24),
      header: (context) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 12),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Historial de ordenes de trabajo',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Bomberos Voluntarios de Lomas de Zamora - '
              'Emitido el ${formatDateTime(DateTime.now())} - '
              '${ordenes.length} ordenes',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
      ),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Pagina ${context.pageNumber} de ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ),
      build: (context) => [
        pw.TableHelper.fromTextArray(
          headers: encabezadosPdf,
          data: filas,
          headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellStyle: const pw.TextStyle(fontSize: 8),
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          // Las filas alternadas hacen seguible una tabla ancha.
          oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
          columnWidths: {4: const pw.FlexColumnWidth(2.2)},
        ),
      ],
    ),
  );

  await FileSaver.instance.saveFile(
    name: _nombreArchivo(),
    bytes: await doc.save(),
    fileExtension: 'pdf',
    mimeType: MimeType.pdf,
  );
}
