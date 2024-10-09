import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entity/medication.dart';
import '../interfaces/i_medication_repository.dart';

final class MedicationRepository implements IMedicationRepository {
  final FirebaseFirestore _firestore;

  MedicationRepository(this._firestore);

  @override
  Future<void> saveMedication(String userId, Map<String, dynamic> medicationData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('medication')
        .doc(medicationData['id'])
        .set(medicationData);
  }

  @override
  Stream<List<Medication>> requestMedications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('medication')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Medication.fromJson(doc.data())).toList());
  }

  @override
  Future<void> removeMedication(String userId, String medicationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('medication')
        .doc(medicationId)
        .delete();
  }
}
