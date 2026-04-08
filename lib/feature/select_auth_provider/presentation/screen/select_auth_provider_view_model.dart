import 'dart:async';

import 'package:capstone_2026/core/domain/repository/auth_repository.dart';
import 'package:capstone_2026/feature/select_auth_provider/presentation/screen/select_auth_provider_action.dart';
import 'package:capstone_2026/feature/select_auth_provider/presentation/screen/select_auth_provider_event.dart';
import 'package:capstone_2026/feature/select_auth_provider/presentation/screen/select_auth_provider_state.dart';
import 'package:flutter/material.dart';

class SelectAuthProviderViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  SelectAuthProviderViewModel({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  SelectAuthProviderState _state = SelectAuthProviderState();

  SelectAuthProviderState get state => _state;

  final StreamController<SelectAuthProviderEvent> _eventController =
      StreamController<SelectAuthProviderEvent>.broadcast();

  Stream<SelectAuthProviderEvent> get eventStream => _eventController.stream;

  void onAction(SelectAuthProviderAction action) {
    switch (action) {
      case TapBackButton():
      case TapSignUpWithEmailButton():
      case TapSignIn():
        break;
      case TapSignUpWithGoogleButton():
        _signUpWithGoogle();
        break;
      case TapSignUpWithKakaoButton():
        _signUpWithKakao();
        break;
      case TapSignUpWithNaverButton():
        // TODO: 각 플랫폼에 맞게 회원가입 로직 연결할 것
        break;
    }
  }

  Future<void> _signUpWithGoogle() async {
    // 중복 실행 방지
    if (state.isLoading) return;

    _state = state.copyWith(isLoading: true);
    notifyListeners();

    // TODO: 사용자 취소로 인해 예외 발생 시에는 스낵바 표시하지 말아야 함.
    try {
      await _authRepository.signInWithGoogle();
      notifyListeners();
    } catch (e) {
      _eventController.add(
        SelectAuthProviderEvent.showGoogleSignInError(e.toString()),
      );
    } finally {
      _state = state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  Future<void> _signUpWithKakao() async {
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

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
