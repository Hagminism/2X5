import 'dart:async';

import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_action.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_event.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_state.dart';
import 'package:flutter/foundation.dart';

class SignUpCustomerViewModel extends ChangeNotifier {
  SignUpCustomerState _state = const SignUpCustomerState();

  SignUpCustomerState get state => _state;

  final StreamController<SignUpCustomerEvent> _eventController =
      StreamController<SignUpCustomerEvent>();

  Stream<SignUpCustomerEvent> get eventStream => _eventController.stream;

  Future<void> onAction(SignUpCustomerAction action) async {
    switch (action) {
      case ToggleTermsAgreement():
        _toggleTermsAgreement();
        break;
      case ChangePasswordObscureText():
        _changePasswordObscureText();
        break;
      case ChangePasswordConfirmObscureText():
        _changePasswordConfirmObscureText();
        break;
      case TapBackButton():
      case TapSubmit():
        // TODO: 회원가입 제출 로직 추가할 것
        break;
    }
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

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
