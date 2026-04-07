import 'package:firebase_auth/firebase_auth.dart';

abstract interface class AuthRepository {
  // 구글
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Future<void> deleteAccount();
  User? getCurrentUser();
  Stream<User?> authStateChanges();

  // 카카오
  Future<void> signInWithKakao();
}
