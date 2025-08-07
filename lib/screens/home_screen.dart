// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha
import 'package:sorteo_ipv_web/model/ganador_model.dart';
import '../controllers/controller.dart';

class HomeScreenWeb extends StatelessWidget {
  const HomeScreenWeb({super.key});

  // Método para mostrar el diálogo de carga mientras se exporta a Excel
  void _exportExcelWithLoading(
    GanadoresWebController controller,
    ExportExcelController exportController,
  ) async {
    // Muestra el diálogo de carga
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    // Llama al método de exportación del controlador
    await exportController.exportarExcel(
      controller.ganadoresAgrupadosPorManzana,
    );

    // Cierra el diálogo de carga
    Get.back();
  }

  // Método para mostrar el diálogo de carga mientras se exporta a PDF
  void _exportPdfWithLoading(
    GanadoresWebController controller,
    ExportPdfController exportController,
  ) async {
    // Muestra el diálogo de carga
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    // Llama al método de exportación del controlador
    await exportController.exportarPdf(controller.ganadoresAgrupadosPorManzana);

    // Cierra el diálogo de carga
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    // Inicializar los controladores
    final GanadoresWebController controller = Get.put(GanadoresWebController());
    final ExportExcelController exportExcelController = Get.put(
      ExportExcelController(),
    );
    final ExportPdfController exportPdfController = Get.put(
      ExportPdfController(),
    );

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'POSICIONES DE ADJUDICACIÓN LOTES BARRIO VALLE DEL SOL - IPV 2025',
        ),
        backgroundColor: Colors.orangeAccent,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.listenToGanadores(),
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.orangeAccent),
              child: Center(
                child: Text(
                  'Opciones de Exportación',
                  style: TextStyle(color: Colors.white, fontSize: width * 0.02),
                ),
              ),
            ),
            // Botón para exportar a Excel
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Exportar a Excel'),
              onTap: () {
                _exportExcelWithLoading(controller, exportExcelController);
                Navigator.of(context).pop(); // Cierra el Drawer
              },
            ),
            // Botón para exportar a PDF
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Exportar a PDF'),
              onTap: () {
                _exportPdfWithLoading(controller, exportPdfController);
                Navigator.of(context).pop(); // Cierra el Drawer
              },
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.ganadoresAgrupadosPorManzana.isEmpty) {
          return const Center(
            child: Text(
              'Aún no hay ganadores sorteados para mostrar.',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        final List<String> manzanasOrdenadas = controller
            .ganadoresAgrupadosPorManzana
            .keys
            .toList();

        // Ordenamos las manzanas numéricamente (ej. M1, M2, M10)
        manzanasOrdenadas.sort((a, b) {
          // Extraemos solo los dígitos de la cadena de la manzana para evitar errores de formato
          final numA = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          final numB = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          return numA.compareTo(numB);
        });

        // Usamos LayoutBuilder para adaptar el GridView al tamaño de la pantalla
        return LayoutBuilder(
          builder: (context, constraints) {
            // Un grid de 4x5 para un total de 20 contenedores
            const int crossAxisCount = 4;
            const int totalRows = 5;

            // Calculamos paddings y espaciados de forma responsive
            final double mainPadding = width * 0.005;
            final double cardSpacing = width * 0.005;

            // Calcula la altura de cada contenedor para que quepan 5 filas
            final double cardHeight =
                constraints.maxHeight / totalRows - (mainPadding * 2);

            // Calcula el aspect ratio basándose en el ancho y alto del contenedor
            final double cardWidth =
                (constraints.maxWidth / crossAxisCount) - (mainPadding * 2);
            final double childAspectRatio = cardWidth / cardHeight;

            // Calculamos el tamaño de fuente de forma responsive
            final double baseFontSize = width * 0.008;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: cardSpacing,
                mainAxisSpacing: cardSpacing,
                childAspectRatio: childAspectRatio,
              ),
              padding: EdgeInsets.all(mainPadding),
              itemCount: manzanasOrdenadas.length,
              itemBuilder: (context, index) {
                final String manzana = manzanasOrdenadas[index];
                final List<GanadorWebModel> ganadoresEnManzana =
                    controller.ganadoresAgrupadosPorManzana[manzana]!;

                // Ordenamos los ganadores de forma inversa (el último agregado, primero)
                final List<GanadorWebModel> ganadoresInvertidos =
                    ganadoresEnManzana.reversed.toList();

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(mainPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MANZANA: $manzana',
                          style: TextStyle(
                            fontSize: baseFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const Divider(height: 10, thickness: 1),
                        // Scroll interno para la lista de ganadores
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(ganadoresInvertidos.length, (
                                innerIndex,
                              ) {
                                final ganador = ganadoresInvertidos[innerIndex];
                                // El último ganador es ahora el primero en la lista invertida (índice 0)
                                final isLastWinner = innerIndex == 0;
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: height * 0.002,
                                  ),
                                  child: Container(
                                    // Agregamos un Container para el efecto de fondo
                                    padding: EdgeInsets.all(width * 0.003),
                                    decoration: BoxDecoration(
                                      color: isLastWinner
                                          ? Colors.green[50]
                                          : Colors.transparent,
                                      borderRadius: isLastWinner
                                          ? BorderRadius.circular(4)
                                          : null,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'LOTE ${ganador.loteNombre}: ${ganador.nombreCompleto}',
                                              style: TextStyle(
                                                fontSize: isLastWinner
                                                    ? baseFontSize * 1.1
                                                    : baseFontSize,
                                                fontWeight: isLastWinner
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              ' - DNI: ${ganador.dniGanador}',
                                              style: TextStyle(
                                                fontSize: isLastWinner
                                                    ? baseFontSize * 1.1
                                                    : baseFontSize,
                                                fontWeight: isLastWinner
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          DateFormat(
                                            'HH:mm',
                                          ).format(ganador.fechaSorteo!),
                                          style: TextStyle(
                                            fontSize: baseFontSize * 0.8,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}
