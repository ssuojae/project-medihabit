import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:medihabit/data/services/implements/medication_service.dart';
import 'package:mockito/mockito.dart';
import 'package:medihabit/domain/entity/medication.dart';

import '../repository/mock/mock_repositories.mocks.dart';

void main() {
  late MockIMedicationRepository mockMedicationRepository;
  late MedicationService medicationService;

  setUp(() {
    mockMedicationRepository = MockIMedicationRepository();
    medicationService = MedicationService(mockMedicationRepository);
  });

  test('given: 복용약이 있을 때, when: addMedication을 호출하면, then: 저장이 성공해야 한다', () async {
    // given
    final medication = Medication(
      id: 'med_1',
      name: 'Test Medication',
      colorHex: Color(0xFFFFFFFF),
      description: 'Test Description',
      time: DateTime.now(),
      imageUrl: 'http://example.com/image.jpg',
    );

    // when
    when(mockMedicationRepository.saveMedication(any, any))
        .thenAnswer((_) async => {});

    await medicationService.addMedication('user_123', medication);

    // then
    verify(mockMedicationRepository.saveMedication('user_123', medication.toJson()))
        .called(1);
  });

  test('given: 주어진 복용약을 가지고, when: removeMedication을 호출하면, then: 삭제가 성공해야 한다', () async {
    // given
    final medicationId = 'med_1';

    // when
    when(mockMedicationRepository.removeMedication(any, any))
        .thenAnswer((_) async => {});

    await medicationService.removeMedication('user_123', medicationId);

    // then
    verify(mockMedicationRepository.removeMedication('user_123', medicationId))
        .called(1);
  });

  test('given: 유저와 복용약이 있을 때, when: fetchMedications을 호출하면, then: 스트림으로 데이터가 반환되어야 한다', () async {
    // given
    final userId = 'user_123';
    final medications = [
      Medication(
        id: 'med_1',
        name: 'Test Medication',
        colorHex: Color(0xFFFFFFFF),
        description: 'Test Description',
        time: DateTime.now(),
        imageUrl: 'http://example.com/image.jpg',
      ),
    ];

    // when
    when(mockMedicationRepository.requestMedications(userId))
        .thenAnswer((_) => Stream.value(medications));
    final stream = medicationService.fetchMedications(userId);

    // then
    await expectLater(stream, emitsInOrder([medications]));
  });
}
