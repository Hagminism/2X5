import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/screen/my_page_state.dart';
import 'package:flutter/material.dart';

class MyPageViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  MyPageViewModel({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  MyPageState _state = MyPageState();

  MyPageState get state => _state;

  Future<void> fetchProfile() async {
    // 중복 호출 방지
    if (state.isLoading) return;

    _state = state.copyWith(isLoading: true);
    notifyListeners();

    final user = _authRepository.getCurrentUser();

    _state = state.copyWith(
      isLoading: false,
      userName: user?.displayName,
      email: user?.email,
      photoUrl: user?.photoURL,
    );
    notifyListeners();
  }
}
