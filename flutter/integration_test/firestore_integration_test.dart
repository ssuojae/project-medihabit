import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medihabit/domain/entity/medication.dart';
import 'package:medihabit/domain/entity/user.dart';
import 'package:flutter/material.dart';

void main() {
  late FirebaseFirestore firestore;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  setUp(() {
    firestore = FirebaseFirestore.instance;
  });

  group('Firestore Medication Integration Test', () {
    test('Firestore에 Medication 데이터를 저장하고 불러와서 모델과 일치하는지 검증', () async {
      // given
      final medication = Medication(
        id: 'med_1',
        name: 'Test Medication',
        colorHex: const Color(0xFFFFFFFF),
        description: 'Test Description',
        time: DateTime.now(),
        imageUrl: 'http://example.com/image.jpg',
      );

      // Firestore에 데이터 저장
      await firestore.collection('medications').doc(medication.id).set(medication.toJson());

      // Firestore에서 데이터 읽어오기
      final docSnapshot = await firestore.collection('medications').doc(medication.id).get();
      final data = docSnapshot.data();

      // 읽어온 데이터를 Medication 모델로 변환
      final fetchedMedication = Medication.fromJson(data!);

      // then
      expect(fetchedMedication, equals(medication));
    });
  });

  group('Firestore User Integration Test', () {
    test('Firestore에 User 데이터를 저장하고 불러와서 모델과 일치하는지 검증', () async {
      // given
      final user = User(
        id: 'user_1',
        name: 'Test User',
        email: 'testuser@example.com',
        photoUrl: 'http://example.com/photo.jpg',
      );

      // Firestore에 데이터 저장
      await firestore.collection('users').doc(user.id).set(user.toJson());

      // Firestore에서 데이터 읽어오기
      final docSnapshot = await firestore.collection('users').doc(user.id).get();
      final data = docSnapshot.data();

      // 읽어온 데이터를 User 모델로 변환
      final fetchedUser = User.fromJson(data!);

      // then
      expect(fetchedUser, equals(user));
    });
  });
}
