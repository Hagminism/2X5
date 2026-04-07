import 'package:capstone_2026/core/domain/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' hide User;

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final UserApi _userApi;

  const AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required UserApi userApi,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn,
       _userApi = userApi;

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
    // 카카오 로그인 구현 예제

    // 카카오톡 실행 가능 여부 확인
    // 카카오톡 실행이 가능하면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
    if (await isKakaoTalkInstalled()) {
      try {
        await _userApi.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }

        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await _userApi.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await _userApi.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }
  }
}
