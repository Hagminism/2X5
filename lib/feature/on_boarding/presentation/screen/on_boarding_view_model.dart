import 'package:capstone_2026/core/domain/model/enum/user_type.dart';
import 'package:capstone_2026/core/domain/model/user/user.dart';
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
    final firebaseUser = _authRepository.getCurrentUser();

    if (firebaseUser == null) {
      throw Exception('로그인 정보가 없습니다.');
    }

    await _userRepository.createUser(
      User(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        userType: userType,
        email: firebaseUser.email ?? '',
        phone: firebaseUser.phoneNumber ?? '',
        imageUrl: firebaseUser.photoURL ?? '',
      ),
    );
  }
}
