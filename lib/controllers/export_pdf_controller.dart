// lib/controllers/export_pdf_controller.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sorteo_ipv_web/model/ganador_model.dart';

class ExportPdfController extends GetxController {
  // Estado de exportación para el botón en la UI
  var isExportingPdf = false.obs;

  /// Exporta los ganadores a un archivo PDF y lo descarga en el navegador.
  Future<void> exportarPdf(
    Map<String, List<GanadorWebModel>> ganadoresAgrupadosPorManzana,
  ) async {
    isExportingPdf.value = true;
    try {
      final pdf = pw.Document();

      // Cargar la imagen del logo (usar un placeholder ya que no se tiene la ruta)
      final ByteData image = await rootBundle.load('assets/images/logo.png');
      final Uint8List imageBytes = image.buffer.asUint8List();

      // Preparar los datos para la tabla
      final List<List<dynamic>> filasTabla = [];
      ganadoresAgrupadosPorManzana.forEach((manzana, ganadores) {
        for (var ganador in ganadores) {
          final formattedDate = DateFormat(
            'dd/MM/yyyy HH:mm',
          ).format(ganador.fechaSorteo!);
          filasTabla.add([
            ganador.manzanaNombre!,
            ganador.loteNombre!,
            ganador.nombreCompleto!,
            ganador.dniGanador!,
            formattedDate,
          ]);
        }
      });

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            // Logo centrado
            pw.Center(child: pw.Image(pw.MemoryImage(imageBytes), height: 100)),
            pw.SizedBox(height: 20),
            // Título
            pw.Center(
              child: pw.Text(
                'Listado de Ganadores del Sorteo',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            // Tabla de ganadores
            pw.Table.fromTextArray(
              headers: [
                'Manzana',
                'Lote',
                'Nombre Completo',
                'DNI',
                'Fecha Sorteo',
              ],
              data: filasTabla,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey600),
            ),
          ],
        ),
      );

      // Guardar y descargar el archivo
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'ganadores_sorteo.pdf',
      );

      Get.snackbar(
        'Exportación Exitosa',
        'El archivo ganadores_sorteo.pdf se ha generado.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo exportar el archivo: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isExportingPdf.value = false;
    }
  }
}
