// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sorteo_ipv_web/model/ganador_model.dart';

class GanadoresWebController extends GetxController {
  // Un mapa para guardar los ganadores agrupados por el nombre de la manzana
  var ganadoresAgrupadosPorManzana = <String, List<GanadorWebModel>>{}.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Escuchar los ganadores en tiempo real
    listenToGanadores();
  }

  // Método para escuchar los datos de Firestore en tiempo real
  void listenToGanadores() {
    isLoading.value = true;

    FirebaseFirestore.instance
        .collection('ganadores')
        .orderBy(
          'manzanaNombre',
        ) // Ordenar por manzana para una mejor agrupación
        .orderBy(
          'loteNombre',
        ) // Luego por lote para un orden dentro de la manzana
        .snapshots()
        .listen(
          (snapshot) {
            // Crear un mapa temporal para la nueva agrupación
            Map<String, List<GanadorWebModel>> tempGroupedWinners = {};

            for (var doc in snapshot.docs) {
              final ganador = GanadorWebModel.fromMap(doc.id, doc.data());
              if (!tempGroupedWinners.containsKey(ganador.manzanaNombre)) {
                tempGroupedWinners[ganador.manzanaNombre] = [];
              }
              tempGroupedWinners[ganador.manzanaNombre]!.add(ganador);
            }
            ganadoresAgrupadosPorManzana.value = tempGroupedWinners;
            isLoading.value = false;
          },
          onError: (error) {
            isLoading.value = false;
            Get.snackbar(
              'Error',
              'Hubo un problema al cargar los ganadores para la web.',
            );
            print('Error al escuchar ganadores para la web: $error');
          },
        );
  }
}
