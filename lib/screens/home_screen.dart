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
          'Tabla de Posiciones - Sorteo IPV Barrio Villa del Sol',
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

        // Encontrar al último ganador de forma global
        GanadorWebModel? ultimoGanador;
        DateTime? ultimaFechaSorteo;
        for (var ganadores in controller.ganadoresAgrupadosPorManzana.values) {
          for (var ganador in ganadores) {
            if (ultimoGanador == null ||
                ganador.fechaSorteo!.isAfter(ultimaFechaSorteo!)) {
              ultimoGanador = ganador;
              ultimaFechaSorteo = ganador.fechaSorteo;
            }
          }
        }

        // Altura del contenedor fijo en la parte inferior
        const double footerHeight = 60;
        final bool showFooter = ultimoGanador != null;

        return Stack(
          children: [
            // Contenido principal de las manzanas (la lista de ganadores)
            Positioned.fill(
              bottom: showFooter
                  ? footerHeight
                  : 0, // Ajustamos el espacio para el footer
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const int crossAxisCount = 4;
                  const int totalRows = 5;
                  final double mainPadding = width * 0.005;
                  final double cardSpacing = width * 0.005;

                  // Ajustamos la altura de cada contenedor para que quepan 5 filas en el espacio disponible
                  final double cardHeight =
                      constraints.maxHeight / totalRows - (mainPadding * 2);

                  final double cardWidth =
                      (constraints.maxWidth / crossAxisCount) -
                      (mainPadding * 2);
                  final double childAspectRatio = cardWidth / cardHeight;
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
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: List.generate(
                                      ganadoresInvertidos.length,
                                      (innerIndex) {
                                        final ganador =
                                            ganadoresInvertidos[innerIndex];
                                        final isLastWinner = innerIndex == 0;
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: height * 0.002,
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.all(
                                              width * 0.003,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isLastWinner
                                                  ? Colors.green.shade200
                                                  : Colors.transparent,
                                              borderRadius: isLastWinner
                                                  ? BorderRadius.circular(4)
                                                  : null,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  'DNI: ${ganador.dniGanador}',
                                                  style: TextStyle(
                                                    fontSize: isLastWinner
                                                        ? baseFontSize * 1.1
                                                        : baseFontSize,
                                                    fontWeight: isLastWinner
                                                        ? FontWeight.bold
                                                        : FontWeight.w600,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  DateFormat('HH:mm').format(
                                                    ganador.fechaSorteo!,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize:
                                                        baseFontSize * 0.8,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
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
              ),
            ),
            // Contenedor fijo en la parte inferior para el último ganador
            if (showFooter)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: footerHeight,
                child: Container(
                  width: double.infinity,
                  color: Colors.green.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '¡ÚLTIMO POSICIONADO! MANZANA ${ultimoGanador!.manzanaNombre}, LOTE ${ultimoGanador.loteNombre}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: width * 0.02),
                      Text(
                        '${ultimoGanador.nombreCompleto}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: width * 0.015),
                      Text(
                        'DNI: ${ultimoGanador.dniGanador}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
