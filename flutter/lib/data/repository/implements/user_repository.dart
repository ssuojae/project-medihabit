// 다트 패키지
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// 외부 패키지
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 파일
import 'package:medihabit/domain/entity/user.dart' as domain;
import 'package:medihabit/presentation/utils/app_images.dart';
import '../interfaces/i_user_repository.dart';

final class UserRepository implements IUserRepository {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  UserRepository(this._firestore, this._firebaseAuth);

  @override
  Future<void> signInWithGoogle() async {
    await GoogleSignIn()
        .signIn()
        .then((googleUser) => googleUser!.authentication)
        .then((googleAuth) => firebase_auth.GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            ))
        .then((credential) => _firebaseAuth.signInWithCredential(credential))
        .then((firebaseAuthCredential) => _convertToDomainUser(id: firebaseAuthCredential.user!.uid))
        .then((userEntity) => _storeUserInFirestore(userEntity))
        .catchError((error) => debugPrint('Google Sign-in Error: $error'));
  }

  @override
  Future<void> signInWithApple() async {
    SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
    )
        .then((appleCredential) => firebase_auth.OAuthProvider('apple.com').credential(
              idToken: appleCredential.identityToken,
              accessToken: appleCredential.authorizationCode,
            ))
        .then((credential) => _firebaseAuth.signInWithCredential(credential))
        .then((userCredential) => _convertToDomainUser(
              id: userCredential.user!.uid,
              name: userCredential.additionalUserInfo!.profile!['givenName'],
              email: userCredential.user!.email!,
              photoUrl: AppImages.profileIcon,
            ))
        .then((userEntity) => _storeUserInFirestore(userEntity))
        .catchError((error) => debugPrint('Apple Sign-in Error: $error'));
  }

  @override
  Future<void> signInWithKakao() async {
    kakao.User? kakaoUser;

    await _fetchKakaoToken()
        .then((token) => kakao.UserApi.instance.me().then((user) async {
              kakaoUser = user;
              token = await _requestKakaoPermissions(token, kakaoUser!);

              return firebase_auth.OAuthProvider('oidc.medihabit').credential(
                accessToken: token.accessToken,
                idToken: token.idToken,
              );
            }))
        .then((credential) => _firebaseAuth.signInWithCredential(credential))
        .then((userCredential) => _convertToDomainUser(
              id: userCredential.user!.uid,
              name: kakaoUser!.kakaoAccount!.profile!.nickname!,
              email: kakaoUser!.kakaoAccount!.email!,
              photoUrl: kakaoUser!.kakaoAccount!.profile!.profileImageUrl!,
            ))
        .then((userEntity) => _storeUserInFirestore(userEntity))
        .catchError((error) => debugPrint('Kakao Sign-in Error: $error'));
  }

  domain.User _convertToDomainUser({
    required String id,
    String name = 'N/A',
    String email = 'N/A',
    String photoUrl = 'N/A',
  }) {
    return domain.User(
      id: id,
      name: name,
      email: email,
      photoUrl: photoUrl,
    );
  }

  Future<void> _storeUserInFirestore(domain.User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson(), SetOptions(merge: true));
  }

  Future<kakao.OAuthToken> _fetchKakaoToken() async {
    return kakao
        .isKakaoTalkInstalled()
        .then<kakao.OAuthToken>(
          (isInstalled) => isInstalled
              ? kakao.UserApi.instance.loginWithKakaoTalk()
              : kakao.UserApi.instance.loginWithKakaoAccount(),
        )
        .catchError((error) => error is PlatformException && error.code == 'CANCELED'
            ? Future<kakao.OAuthToken>.error('Sign-in canceled.')
            : kakao.UserApi.instance.loginWithKakaoAccount());
  }

  Future<kakao.OAuthToken> _requestKakaoPermissions(kakao.OAuthToken token, kakao.User kakaoUser) async {
    final requiredScopes = [
      if (kakaoUser.kakaoAccount?.emailNeedsAgreement == true) 'account_email',
      if (kakaoUser.kakaoAccount?.profileNeedsAgreement == true) 'profile',
    ];

    return requiredScopes.isEmpty
        ? token
        : await kakao.UserApi.instance
            .loginWithNewScopes(requiredScopes)
            .then((newToken) => newToken)
            .catchError((error) {
            debugPrint('Kakao Permission Request Error: $error');
            return token;
          });
  }

  @override
  Future<domain.User?> fetchUser(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          return domain.User.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Fetch User Error: $e');
      return null;
    }
  }

}
