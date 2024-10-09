import 'package:flutter_test/flutter_test.dart';
import 'package:medihabit/data/repository/implements/medication_repository.dart';
import 'package:mockito/mockito.dart';

import 'mock/mock_repositories.mocks.dart';

void main() {
  late MedicationRepository medicationRepository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocument;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocument = MockDocumentReference<Map<String, dynamic>>();

    medicationRepository = MedicationRepository(mockFirestore);
  });

  test('given: 유저가 약물 데이터를 저장할 때, when: saveMedication을 호출하면, then: Firestore에 데이터가 저장되어야 한다', () async {
    // given
    final String userId = 'user_123';
    final Map<String, dynamic> medicationData = {'id': 'med_123', 'name': 'Aspirin'};

    when(mockFirestore.collection('users')).thenReturn(mockCollection);
    when(mockCollection.doc(userId)).thenReturn(mockDocument);
    when(mockDocument.collection('medication')).thenReturn(mockCollection);
    when(mockCollection.doc('med_123')).thenReturn(mockDocument);

    // when
    await medicationRepository.saveMedication(userId, medicationData);

    // then
    verify(mockDocument.set(medicationData)).called(1);
  });

  test('given: 유저가 약물 데이터를 삭제할 때, when: removeMedication을 호출하면, then: Firestore에서 해당 데이터가 삭제되어야 한다', () async {
    // given
    final String userId = 'user_123';
    final String medicationId = 'med_123';

    when(mockFirestore.collection('users')).thenReturn(mockCollection);
    when(mockCollection.doc(userId)).thenReturn(mockDocument);
    when(mockDocument.collection('medication')).thenReturn(mockCollection);
    when(mockCollection.doc(medicationId)).thenReturn(mockDocument);

    // when
    await medicationRepository.removeMedication(userId, medicationId);

    // then
    verify(mockDocument.delete()).called(1);
  });
}
