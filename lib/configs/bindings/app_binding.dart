// ignore: depend_on_referenced_packages
import 'package:get/get.dart';
import 'package:sorteo_ipv_web/controllers/ganadores_web_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(GanadoresWebController());
  }
}
