import 'dart:async';

import 'package:capstone_2026/core/domain/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_action.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_event.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_state.dart';
import 'package:flutter/material.dart';

class AccountSettingViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AccountSettingViewModel({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  AccountSettingState _state = AccountSettingState();

  AccountSettingState get state => _state;

  final StreamController<AccountSettingEvent> _eventController =
      StreamController<AccountSettingEvent>();

  Stream<AccountSettingEvent> get eventStream => _eventController.stream;

  void onAction(AccountSettingAction action) {
    switch (action) {
      case TapBackButton():
        break;
      case TapChangePasswordButton():
        _eventController.add(AccountSettingEvent.showChangePasswordDialog());
        break;
      case TapSignOutButton():
        _eventController.add(AccountSettingEvent.showSignOutDialog());
        break;
      case TapSignOutConfirmButton():
        _signOut();
        break;
      case TapDeleteAccountButton():
        _eventController.add(AccountSettingEvent.showDeleteAccountDialog());
        break;
      case TapDeleteAccountConfirmButton():
        _deleteAccount();
        break;
    }
  }

  Future<void> _signOut() async {
    _state = state.copyWith(isLoading: true);
    notifyListeners();

    await _authRepository.signOut();

    _state = state.copyWith(isLoading: false);
    notifyListeners();
  }

  Future<void> _deleteAccount() async {
    _state = state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await _authRepository.deleteAccount();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // 보안상 중요한 작업은 최근 로그인 기록이 필요
        // 여기서 사용자에게 재로그인을 요청하는 알림을 생성
        // TODO: 스낵바 등으로 사용자에게 고지하면 될 듯?
        print('재로그인이 필요합니다.');
      }
    } catch (e) {
      // TODO: 스낵바 등으로 사용자에게 고지하면 될 듯?
      print('회원 탈퇴 실패: $e');
    } finally {
      _state = state.copyWith(isLoading: false);
      notifyListeners();
    }
  }
}
