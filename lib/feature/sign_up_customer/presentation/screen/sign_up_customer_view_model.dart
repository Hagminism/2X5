import 'dart:async';

import 'package:capstone_2026/core/domain/repository/auth_repository.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_action.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_event.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    final validationErrorMessage = _validateSignUpInput();
    if (validationErrorMessage != null) {
      _eventController.add(
        SignUpCustomerEvent.showSignUpError(validationErrorMessage),
      );
      return;
    }

    _state = state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _authRepository.signUpWithEmail(
        state.email.trim(),
        state.password,
        state.name.trim(),
      );
    } on FirebaseAuthException catch (e) {
      _eventController.add(
        SignUpCustomerEvent.showSignUpError(_mapFirebaseAuthError(e.code)),
      );
    } catch (e) {
      _eventController.add(
        const SignUpCustomerEvent.showSignUpError('회원가입 중 오류가 발생했습니다.'),
      );
    } finally {
      _state = state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  String? _validateSignUpInput() {
    if (state.name.trim().isEmpty) {
      return '이름을 입력해 주세요.';
    }
    if (state.email.trim().isEmpty) {
      return '이메일을 입력해 주세요.';
    }
    if (!_isValidEmail(state.email)) {
      return '올바른 이메일 형식을 입력해 주세요.';
    }
    if (!state.agreeTerms) {
      return '이용약관 및 개인정보 처리방침 동의가 필요합니다.';
    }
    if (state.password != state.passwordConfirm) {
      return '비밀번호 확인이 일치하지 않습니다.';
    }
    if (RegExp(r'\s').hasMatch(state.password)) {
      return '비밀번호에는 공백을 포함할 수 없습니다.';
    }
    if (state.password.length < 8 || state.password.length > 20) {
      return '비밀번호는 8자 이상 20자 이하로 입력해 주세요.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(state.password)) {
      return '비밀번호에 대문자를 1개 이상 포함해 주세요.';
    }
    if (!RegExp(r'[a-z]').hasMatch(state.password)) {
      return '비밀번호에 소문자를 1개 이상 포함해 주세요.';
    }
    if (!RegExp(r'[0-9]').hasMatch(state.password)) {
      return '비밀번호에 숫자를 1개 이상 포함해 주세요.';
    }
    if (!RegExp(
      r'[!@#$%^&*(),.?":{}|<>_\-+=/\\\[\]~`]',
    ).hasMatch(state.password)) {
      return '비밀번호에 특수문자를 1개 이상 포함해 주세요.';
    }
    return null;
  }

  bool _isValidEmail(String email) {
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return pattern.hasMatch(email.trim());
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'weak-password':
      case 'password-does-not-meet-requirements':
        return '비밀번호가 보안 정책을 충족하지 않습니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return '올바른 이메일 형식을 입력해 주세요.';
      case 'network-request-failed':
        return '네트워크 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
      default:
        return '회원가입에 실패했습니다. 입력값을 다시 확인해 주세요.';
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
