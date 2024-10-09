import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:medihabit/data/repository/interfaces/i_user_repository.dart';
import 'package:medihabit/data/repository/interfaces/i_medication_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

@GenerateMocks([
  IUserRepository,
  IMedicationRepository,
  firebase_auth.FirebaseAuth,
  firebase_auth.User,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  QuerySnapshot,
  QueryDocumentSnapshot
])
void main() {}
