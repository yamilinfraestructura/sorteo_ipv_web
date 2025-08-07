import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:sorteo_ipv_web/model/ganador_model.dart';

class ExportExcelController extends GetxController {
  // Estado de exportación para el botón en la UI
  var isExporting = false.obs;

  /// Exporta los ganadores a un archivo Excel y lo descarga en el navegador.
  Future<void> exportarExcel(
    Map<String, List<GanadorWebModel>> ganadoresAgrupadosPorManzana,
  ) async {
    isExporting.value = true;
    try {
      final excel = Excel.createExcel();
      final sheetObject = excel['Ganadores Sorteo'];

      // Agregar encabezados
      sheetObject.appendRow([
        TextCellValue('Manzana'),
        TextCellValue('Lote'),
        TextCellValue('Nombre Completo'),
        TextCellValue('DNI'),
        TextCellValue('Fecha Sorteo'),
      ]);

      // Iterar sobre los ganadores agrupados para llenar la hoja
      ganadoresAgrupadosPorManzana.forEach((manzana, ganadores) {
        for (var ganador in ganadores) {
          final formattedDate = DateFormat(
            'dd/MM/yyyy HH:mm',
          ).format(ganador.fechaSorteo!);
          sheetObject.appendRow([
            TextCellValue(ganador.manzanaNombre!),
            TextCellValue(ganador.loteNombre!),
            TextCellValue(ganador.nombreCompleto!),
            TextCellValue(ganador.dniGanador!),
            TextCellValue(formattedDate),
          ]);
        }
      });

      // Guardar el archivo Excel
      final List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        // En un entorno web, el paquete 'excel' ya maneja la descarga.
        excel.save(fileName: 'ganadores_sorteo.xlsx');

        // Mostrar un mensaje de éxito
        Get.snackbar(
          'Exportación Exitosa',
          'El archivo ganadores_sorteo.xlsx se ha descargado.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Error al generar el archivo Excel.');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo exportar el archivo: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isExporting.value = false;
    }
  }
}
