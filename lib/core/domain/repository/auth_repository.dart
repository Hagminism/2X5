import 'package:firebase_auth/firebase_auth.dart';

abstract interface class AuthRepository {
  Future<void> signInWithGoogle();
  Future<void> signInWithKakao();
  Future<void> signOut();
  Future<void> deleteAccount();
  User? getCurrentUser();
  Stream<User?> authStateChanges();

  // 네이버
  Future<void> requestNaverAuthorization(String state);
  Future<Map<String, dynamic>> exchangeNaverAccessToken(String code, String state);
  Future<void> signInWithNaver(String idToken, String accessToken);
  Future<Map<String, dynamic>> getNaverProfile(String accessToken);
}
