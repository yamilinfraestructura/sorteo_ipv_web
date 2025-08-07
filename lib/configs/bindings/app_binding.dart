// ignore: depend_on_referenced_packages
import 'package:get/get.dart';

import '../../controllers/controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(GanadoresWebController());
    Get.put(ExportExcelController());
    Get.put(ExportPdfController());
  }
}
