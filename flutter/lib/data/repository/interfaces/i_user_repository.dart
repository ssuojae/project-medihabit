import '../../../domain/entity/user.dart';

abstract interface class IUserRepository {
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> signInWithKakao();
  Future<User?> fetchUser(String userId);
}