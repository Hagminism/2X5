import 'package:capstone_2026/core/domain/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  const AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn;

  @override
  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.authenticate();

    // Obtain the auth details from the request
    final googleAuth = googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    await _firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    // 1. 유저 로그인 상태 확인
    final currentUser = _firebaseAuth.currentUser;

    // 2. 로그인 정보 최신 상태로 갱신
    // release에서는, attemptLightweightAuthentication 진행 중 사용자가 취소하면
    // idToken이 null이 되어 비정상적인 credential 값이 생생되고,
    // reauthenticateWithCredential에서 FirebaseAuthMultiFactorException 발생
    final googleUser = await _googleSignIn.attemptLightweightAuthentication();
    final googleAuth = googleUser?.authentication;

    if (googleAuth?.idToken == null) {
      throw Exception('재인증에 실패했습니다. 다시 시도해주십시오.');
    }

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth?.idToken,
    );

    await currentUser?.reauthenticateWithCredential(credential);

    // 3. Firebase에서 해당 사용자 삭제
    await currentUser?.delete();
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  @override
  Future<void> signInWithKakao() async {
    final provider = OAuthProvider("oidc.kakao"); // 콘솔에서 정한 이름
    await _firebaseAuth.signInWithProvider(provider);
  }
}
