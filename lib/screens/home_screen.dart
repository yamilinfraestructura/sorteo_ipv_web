import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha
import 'package:sorteo_ipv_web/model/ganador_model.dart';
import '../controllers/ganadores_web_controller.dart';

class HomeScreenWeb extends StatelessWidget {
  const HomeScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializar el controlador
    final GanadoresWebController controller = Get.put(GanadoresWebController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganadores por Manzana (Web)'),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.listenToGanadores(),
          ),
        ],
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

        // Obtener las claves (nombres de manzana) y ordenarlas
        final List<String> manzanasOrdenadas =
            controller.ganadoresAgrupadosPorManzana.keys.toList()..sort();

        return ListView.builder(
          itemCount: manzanasOrdenadas.length,
          itemBuilder: (context, index) {
            final String manzana = manzanasOrdenadas[index];
            final List<GanadorWebModel> ganadoresEnManzana =
                controller.ganadoresAgrupadosPorManzana[manzana]!;

            return Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manzana: $manzana',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const Divider(height: 20, thickness: 2),
                    ...ganadoresEnManzana.map((ganador) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.blueGrey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${ganador.nombreCompleto} (Lote: ${ganador.loteNombre})',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Sorteado: ${ganador.fechaSorteo != null ? DateFormat('dd/MM/yyyy HH:mm').format(ganador.fechaSorteo!) : 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
