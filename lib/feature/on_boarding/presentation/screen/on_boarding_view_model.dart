import 'dart:async';

import 'package:capstone_2026/core/domain/model/enum/auth_provider.dart';
import 'package:capstone_2026/core/domain/model/enum/user_type.dart';
import 'package:capstone_2026/core/domain/model/user/user.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/domain/repository/user/user_repository.dart';
import 'package:capstone_2026/core/routing/core/component/user_registration_status_notifier.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_action.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_event.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_state.dart';
import 'package:flutter/material.dart';

class OnBoardingViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final UserRegistrationStatusNotifier _userRegistrationStatusNotifier;

  OnBoardingViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required UserRegistrationStatusNotifier userRegistrationStatusNotifier,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _userRegistrationStatusNotifier = userRegistrationStatusNotifier;

  OnBoardingState _state = OnBoardingState();

  OnBoardingState get state => _state;

  final StreamController<OnBoardingEvent> _eventController =
      StreamController<OnBoardingEvent>();

  Stream<OnBoardingEvent> get eventStream => _eventController.stream;

  Future<void> onAction(OnBoardingAction action) async {
    switch (action) {
      case TapCustomer():
        await _signUpAsCustomer(action.userType);
        break;
      case TapPartner():
        await _signUpAsPartner(action.userType);
        break;
    }
  }

  Future<void> _signUpAsCustomer(UserType userType) async {
    await _createUser(userType);
  }

  Future<void> _signUpAsPartner(UserType userType) async {
    await _createUser(userType);
  }

  Future<void> _createUser(UserType userType) async {
    _state = state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final firebaseUser = _authRepository.getCurrentUser();

      if (firebaseUser == null) {
        throw Exception('로그인 정보가 없습니다.');
      }

      await _userRepository.createUser(
        User(
          id: firebaseUser.uid,
          authProvider: _convertAuthProvider(
            firebaseUser.providerData.first.providerId,
          ),
          name: firebaseUser.displayName ?? '',
          userType: userType,
          email: firebaseUser.email ?? '',
          phone: firebaseUser.phoneNumber ?? '',
          imageUrl: firebaseUser.photoURL ?? '',
        ),
      );
      await _userRegistrationStatusNotifier.refresh(firebaseUser.uid);
    } catch (e) {
      _eventController.add(OnBoardingEvent.showError(e.toString()));
      rethrow;
    } finally {
      _state = state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  AuthProvider _convertAuthProvider(String authProvider) {
    AuthProvider result = AuthProvider.email;

    switch (authProvider) {
      case 'password':
        result = AuthProvider.email;
        break;
      case 'google.com':
        result = AuthProvider.google;
        break;
      case 'oidc.naver':
        result = AuthProvider.naver;
        break;
      case 'oidc.kakao':
        result = AuthProvider.kakao;
        break;
    }

    return result;
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
