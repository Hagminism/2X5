import 'package:capstone_2026/core/domain/model/enum/user_type.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/domain/repository/user/user_repository.dart';
import 'package:capstone_2026/feature/on_boarding/presentation/screen/on_boarding_action.dart';
import 'package:flutter/material.dart';

class OnBoardingViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  OnBoardingViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository;

  void onAction(OnBoardingAction action) {
    switch (action) {
      case TapCustomer():
        signUpAsCustomer(action.userType);
        break;
      case TapPartner():
        signUpAsPartner(action.userType);
        break;
    }
  }

  Future<void> signUpAsCustomer(UserType userType) async {
    // TODO: 실제 로직 추가해야됨.
  }

  Future<void> signUpAsPartner(UserType userType) async {
    // TODO: 실제 로직 추가해야됨.
  }
}
