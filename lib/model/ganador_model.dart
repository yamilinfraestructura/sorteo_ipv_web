// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';

class GanadorWebModel {
  final String id;
  final String participanteId;
  final String manzanaId; // ¡Campo manzanaId añadido!
  final String nombreCompleto;
  final String manzanaNombre;
  final String loteNombre;
  final DateTime? fechaSorteo;

  GanadorWebModel({
    required this.id,
    required this.participanteId,
    required this.manzanaId, // Requerido en el constructor
    required this.nombreCompleto,
    required this.manzanaNombre,
    required this.loteNombre,
    this.fechaSorteo,
  });

  factory GanadorWebModel.fromMap(String id, Map<String, dynamic> data) {
    return GanadorWebModel(
      id: id,
      participanteId: data['participanteId'] ?? '',
      manzanaId: data['manzanaId'] ?? '', // Mapeo del campo manzanaId
      nombreCompleto: data['nombreCompleto'] ?? '',
      manzanaNombre: data['manzanaNombre'] ?? '',
      loteNombre: data['loteNombre'] ?? '',
      fechaSorteo: data['fechaSorteo'] != null
          ? (data['fechaSorteo'] as Timestamp).toDate()
          : null,
    );
  }
}
