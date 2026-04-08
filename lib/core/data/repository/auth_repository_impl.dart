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
  Future<void> signInWithKakao() async {
    final provider = OAuthProvider("oidc.kakao");
    await _firebaseAuth.signInWithProvider(provider);
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

    // 사용자가 없는 경우, FirebaseAuthException을 통해 스낵바 표출.
    if (currentUser == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: '로그인 정보가 없습니다. 다시 로그인해주세요.',
      );
    }

    // 2. 어떤 인증 제공자로 로그인했는지 확인
    final providerId = currentUser.providerData.isNotEmpty
        ? currentUser.providerData.first.providerId
        : '';

    if (providerId == 'google.com') {
      // 로그인 정보 최신 상태로 갱신
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

      await currentUser.reauthenticateWithCredential(credential);
    } else if (providerId == 'oidc.kakao') {
      // 카카오는 OAuthProvider를 사용하여 재로그인을 유도
      final provider = OAuthProvider("oidc.kakao");

      await currentUser.reauthenticateWithProvider(provider);
    } else {
      // 이메일 로그인 등 다른 수단이 있다면 여기에 추가
      throw Exception('지원하지 않는 인증 수단입니다.');
    }

    // 3. Firebase에서 해당 사용자 삭제
    await currentUser.delete();
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }
}
