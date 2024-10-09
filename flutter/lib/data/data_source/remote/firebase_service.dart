import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medihabit/presentation/utils/app_images.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

final class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<firebase_auth.UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    final userCredential = await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);

    await _saveGoogleUserToFirestore(userCredential.user, googleUser?.photoUrl);

    return userCredential;
  }

  Future<firebase_auth.UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oAuthProvider = firebase_auth.OAuthProvider('apple.com');
    final credential = oAuthProvider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);

    await _saveAppleUserToFirestore(userCredential.user, appleCredential);

    return userCredential;
  }

  Future<firebase_auth.UserCredential> signInWithKakao() async {
    kakao.OAuthToken token = await _getKakaoToken();
    kakao.User kakaoUser = await kakao.UserApi.instance.me();

    token = await _requestKakaoAdditionalScopesIfNeeded(token, kakaoUser);

    final credential = firebase_auth.OAuthProvider('oidc.medihabit').credential(
      accessToken: token.accessToken,
      idToken: token.idToken,
    );

    final userCredential = await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);

    await _saveKakaoUserToFirestore(userCredential.user, kakaoUser);

    return userCredential;
  }

  Future<kakao.OAuthToken> _getKakaoToken() async {
    kakao.OAuthToken token;
    if (await kakao.isKakaoTalkInstalled()) {
      try {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');
        if (error is PlatformException && error.code == 'CANCELED') {
          return Future.error('로그인이 취소되었습니다.');
        }
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }
    } else {
      token = await kakao.UserApi.instance.loginWithKakaoAccount();
    }
    return token;
  }

  Future<kakao.OAuthToken> _requestKakaoAdditionalScopesIfNeeded(
      kakao.OAuthToken token, kakao.User kakaoUser) async {
    List<String> scopes = [];
    if (kakaoUser.kakaoAccount?.emailNeedsAgreement == true) scopes.add('account_email');
    
    if (kakaoUser.kakaoAccount?.profileNeedsAgreement == true) scopes.add('profile');
    
    if (scopes.isNotEmpty) {
      try {
        token = await kakao.UserApi.instance.loginWithNewScopes(scopes);
      } catch (error) {
        print('추가 동의 요청 실패: $error');
      }
    }

    return token;
  }

  Future<void> _saveGoogleUserToFirestore(firebase_auth.User? user, String? photoUrl) async {
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    await userRef.set({
      'id': user.uid,
      'nickname': user.displayName ?? 'N/A',
      'email': user.email ?? 'N/A',
      'photoUrl': photoUrl ?? 'N/A',
    }, SetOptions(merge: true));
    print('Google user info saved to Firestore: ${user.uid}, ${user.displayName}, ${user.email}, ${photoUrl}');
  }

  Future<void> _saveAppleUserToFirestore(firebase_auth.User? user, AuthorizationCredentialAppleID appleCredential) async {
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    await userRef.set({
      'id': user.uid,
      'name': appleCredential.givenName ?? 'N/A',
      'email': appleCredential.email ?? user.email ?? 'N/A',
      'photoUrl': AppImages.profileIcon,  // 애플소셜로그인은 프로필 이미지 제공안하기 때문에 로컬이미지 넣기
    }, SetOptions(merge: true));
    print('Apple user info saved to Firestore: ${user.uid}, ${appleCredential.givenName}, ${appleCredential.email}, ${AppImages.profileIcon}');
  }

  Future<void> _saveKakaoUserToFirestore(firebase_auth.User? user, kakao.User kakaoUser) async {
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    await userRef.set({
      'id': user.uid,
      'name': kakaoUser.kakaoAccount?.profile?.nickname ?? 'N/A',
      'email': kakaoUser.kakaoAccount?.email ?? 'N/A',
      'photoUrl': kakaoUser.kakaoAccount?.profile?.profileImageUrl ?? 'N/A',
    }, SetOptions(merge: true));
    print('Kakao user info saved to Firestore: ${user.uid}, ${kakaoUser.kakaoAccount?.profile?.nickname}, ${kakaoUser.kakaoAccount?.email}, ${kakaoUser.kakaoAccount?.profile?.profileImageUrl}');
  }

  Future<bool> withdrawGoogle() async {
    try {
      await GoogleSignIn().signOut();
      await firebase_auth.FirebaseAuth.instance.currentUser?.delete();
      return true;
    } catch (e) {
      print('Google withdrawal failed: $e');
      return false;
    }
  }
}