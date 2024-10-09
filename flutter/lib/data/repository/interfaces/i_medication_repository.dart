import '../../../domain/entity/medication.dart';

abstract interface class IMedicationRepository {
  Stream<List<Medication>> requestMedications(String userId);
  Future<void> saveMedication(String userId, Map<String, dynamic> medicationData);
  Future<void> removeMedication(String userId, String medicationId);
}
