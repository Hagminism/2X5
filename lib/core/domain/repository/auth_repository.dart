import 'package:firebase_auth/firebase_auth.dart';

abstract interface class AuthRepository {
  Future<void> signInWithGoogle();
  Future<void> signInWithKakao();
  Future<void> signInWithNaver(String accessToken);
  Future<void> signOut();
  Future<void> deleteAccount();
  User? getCurrentUser();
  Stream<User?> authStateChanges();
}
