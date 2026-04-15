import 'dart:async';

import 'package:capstone_2026/core/domain/repository/auth_repository.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_action.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_event.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_state.dart';
import 'package:flutter/foundation.dart';

class SignUpCustomerViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  SignUpCustomerViewModel({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  SignUpCustomerState _state = const SignUpCustomerState();

  SignUpCustomerState get state => _state;

  final StreamController<SignUpCustomerEvent> _eventController =
      StreamController<SignUpCustomerEvent>();

  Stream<SignUpCustomerEvent> get eventStream => _eventController.stream;

  Future<void> onAction(SignUpCustomerAction action) async {
    switch (action) {
      case TapBackButton():
        break;
      case ToggleTermsAgreement():
        _toggleTermsAgreement();
        break;
      case ChangePasswordObscureText():
        _changePasswordObscureText();
        break;
      case ChangePasswordConfirmObscureText():
        _changePasswordConfirmObscureText();
        break;
      case TapSubmit():
        _submit();
        break;
      case ChangeName():
        _changeName(action.name);
        break;
      case ChangeEmail():
        _changeEmail(action.email);
        break;
      case ChangePassword():
        _changePassword(action.password);
        break;
      case ChangePasswordConfirm():
        _changePasswordConfirm(action.passwordConfirm);
        break;
    }
  }

  void _changeName(String name) {
    _state = state.copyWith(name: name);
    notifyListeners();
  }

  void _changeEmail(String email) {
    _state = state.copyWith(email: email);
    notifyListeners();
  }

  void _changePassword(String password) {
    _state = state.copyWith(password: password);
    notifyListeners();
  }

  void _changePasswordConfirm(String passwordConfirm) {
    _state = state.copyWith(passwordConfirm: passwordConfirm);
    notifyListeners();
  }

  void _changePasswordObscureText() {
    _state = state.copyWith(
      passwordObscureText: !state.passwordObscureText,
    );
    notifyListeners();
  }

  void _changePasswordConfirmObscureText() {
    _state = state.copyWith(
      passwordConfirmObscureText: !state.passwordConfirmObscureText,
    );
    notifyListeners();
  }

  void _toggleTermsAgreement() {
    _state = state.copyWith(
      agreeTerms: !state.agreeTerms,
      errorMessage: null,
    );
    notifyListeners();
  }

  Future<void> _submit() async {
    // 중복 실행 방지
    if (state.isLoading) return;

    _state = state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _authRepository.signInWithEmail(
        state.email,
        state.password,
        state.name,
      );
    } catch (e) {
      _eventController.add(
        SignUpCustomerEvent.showGoogleSignUpError(e.toString()),
      );
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
