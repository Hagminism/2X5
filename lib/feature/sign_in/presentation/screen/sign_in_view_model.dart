import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:capstone_2026/core/domain/repository/auth_repository.dart';
import 'package:capstone_2026/feature/sign_in/presentation/screen/sign_in_action.dart';
import 'package:capstone_2026/feature/sign_in/presentation/screen/sign_in_event.dart';
import 'package:flutter/material.dart';

import 'package:capstone_2026/feature/sign_in/presentation/screen/sign_in_state.dart';

class SignInViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  SignInViewModel({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  SignInState _state = SignInState();

  SignInState get state => _state;

  final StreamController<SignInEvent> _eventController =
      StreamController<SignInEvent>.broadcast();

  Stream<SignInEvent> get eventStream => _eventController.stream;

  void onAction(SignInAction action) {
    switch (action) {
      case ChangeObscureText():
        _changeObscureText();
        break;
      case TapGoogleSignInButton():
        _signInWithGoogle();
        break;
      case TapKakaoSignInButton():
        _signInWithKakao();
        break;
      case TapSignInButton():
      case TapNaverSignInButton():
        _signInWithNaver();
        break;
      case MoveToSignUpScreen():
      case MoveToFindPasswordScreen():
        break;
    }
  }

  void _changeObscureText() {
    _state = state.copyWith(
      isObscureText: !state.isObscureText,
    );
    notifyListeners();
  }

  Future<void> _signInWithGoogle() async {
    // 중복 실행 방지
    if (state.isLoading) return;

    _state = state.copyWith(isLoading: true);
    notifyListeners();

    // TODO: 사용자 취소로 인해 예외 발생 시에는 스낵바 표시하지 말아야 함.
    try {
      await _authRepository.signInWithGoogle();
    } catch (e) {
      _eventController.add(SignInEvent.showGoogleSignInError(e.toString()));
    } finally {
      _state = state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  Future<void> _signInWithKakao() async {
    // 중복 실행 방지
    if (state.isLoading) return;

    _state = state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _authRepository.signInWithKakao();
    } finally {
      _state = state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  Future<void> _signInWithNaver() async {
    if (state.isLoading) return;

    final naverState = _generateState();
    _state = state.copyWith(isLoading: true, naverState: naverState);
    notifyListeners();

    try {
      await _authRepository.requestNaverAuthorization(state.naverState);
    } catch (e) {
      _eventController.add(SignInEvent.showNaverSignInError(e.toString()));
      _state = state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> exchangeNaverToken(
    String code,
    String naverState,
  ) async {
    Map<String, dynamic> result = {};

    try {
      result = await _authRepository.exchangeNaverAccessToken(
        code,
        naverState,
      );
    } catch (e) {
      _eventController.add(SignInEvent.showNaverSignInError(e.toString()));
      _state = state.copyWith(isLoading: false);
      notifyListeners();
    }

    return result;
  }

  Future<void> linkNaverWithFirebase(String idToken, String accessToken) async {
    try {
      await _authRepository.signInWithNaver(idToken, accessToken);
    } catch(e) {
      _eventController.add(SignInEvent.showNaverSignInError(e.toString()));
    } finally {
      _state = state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  String _generateState() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', ''); // URL 안전한 문자열로 변환
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
