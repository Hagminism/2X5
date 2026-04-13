import 'dart:convert';

import 'package:capstone_2026/core/domain/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
  Future<void> requestNaverAuthorization(String state) async {
    final authUrl = Uri.parse(
      "https://nid.naver.com/oauth2/authorize"
      "?response_type=code"
      "&client_id=${dotenv.env['NAVER_CLIENT_ID']}"
      "&redirect_uri=${Uri.encodeComponent(dotenv.env['REDIRECT_URI']!)}"
      "&state=$state" // 랜덤 생성한 암호문
      "&scope=openid profile",
    );

    await launchUrl(authUrl, mode: LaunchMode.externalApplication);
  }

  @override
  Future<Map<String, dynamic>> exchangeNaverAccessToken(
    String code,
    String state,
  ) async {
    final response = await http.post(
      Uri.parse('https://nid.naver.com/oauth2/token'),
      body: {
        'grant_type': 'authorization_code',
        'client_id': dotenv.env['NAVER_CLIENT_ID'],
        'client_secret': dotenv.env['NAVER_CLIENT_SECRET'],
        'code': code,
        'state': state,
        'redirect_uri': dotenv.env['REDIRECT_URI'],
      },
    );

    if (response.statusCode != 200) {
      throw Exception('네이버 토큰 교환 실패: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final tokenMap = {
      'id_token': data['id_token'],
      'access_token': data['access_token'],
    };

    return tokenMap;
  }

  @override
  Future<Map<String, dynamic>> getNaverProfile(String accessToken) async {
    final profileResponse = await http.get(
      Uri.parse('https://openapi.naver.com/v1/nid/me'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (profileResponse.statusCode != 200) {
      throw Exception('네이버 프로필 조회 실패: ${profileResponse.body}');
    }

    final result =
        (jsonDecode(profileResponse.body) as Map<String, dynamic>)['response']
            as Map<String, dynamic>;

    return result;
  }

  @override
  Future<void> signInWithNaver(String idToken, String accessToken) async {
    final credential = OAuthProvider("oidc.naver").credential(
      idToken: idToken,
      accessToken: accessToken,
    );

    final naverProfile = await getNaverProfile(accessToken);

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;

    // 정보 업데이트 (동기화)
    if (user != null) {
      await Future.wait([
        user.updateDisplayName(naverProfile['name']),
        user.updatePhotoURL(naverProfile['profile_image']),
        // TODO: 이메일과 전화번호는 추후 수정할 것
        // user.verifyBeforeUpdateEmail(
        //   naverProfile['email'],
        //   ActionCodeSettings(url: 'https://capstone-2026-2x5.web.app'),
        // ),
        // user.updatePhoneNumber(naverProfile['mobile_e164']),
      ]);

      await user.reload(); // 변경사항 확정
    }
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
