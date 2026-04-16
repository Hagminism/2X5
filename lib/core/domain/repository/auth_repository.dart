import 'package:firebase_auth/firebase_auth.dart';

abstract interface class AuthRepository {
  // 구글
  Future<void> signInWithGoogle();
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password, String name);

  // 카카오
  Future<void> signInWithKakao();

  // 네이버
  Future<void> requestNaverAuthorization(String state);
  Future<Map<String, dynamic>> exchangeNaverAccessToken(String code, String state);
  Future<void> signInWithNaver(String idToken, String accessToken);
  Future<Map<String, dynamic>> getNaverProfile(String accessToken);

  // 공통
  Future<void> signOut();
  Future<void> deleteAccount({String? password});
  User? getCurrentUser();
  Stream<User?> authStateChanges();
}
