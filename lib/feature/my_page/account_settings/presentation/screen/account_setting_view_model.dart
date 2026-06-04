import 'dart:async';

import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/presentation/util/user_facing_error_message.dart';
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
        _selectDialogType();
        break;
      case TapDeleteAccountConfirmButton():
      case TapSubmitPasswordButton():
        _deleteAccount();
        break;
      case TypePassword():
        _typePassword(action.password);
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

  void _selectDialogType() {
    final providerId = _authRepository
        .getCurrentUser()!
        .providerData
        .first
        .providerId;

    if (providerId == 'password') {
      _eventController.add(AccountSettingEvent.showEnterPasswordDialog());
    } else {
      _eventController.add(AccountSettingEvent.showDeleteAccountDialog());
    }
  }

  Future<void> _deleteAccount() async {
    if (state.isLoading) return;

    _state = state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final providerId = _authRepository
          .getCurrentUser()!
          .providerData
          .first
          .providerId;

      if (providerId == 'password') {
        await _authRepository.deleteAccount(password: state.password);
      } else {
        await _authRepository.deleteAccount();
      }
    } catch (e) {
      _eventController.add(
        AccountSettingEvent.showErrorMessage(
          userFacingErrorMessage(
            e,
            fallback: '계정 삭제에 실패했습니다. 잠시 후 다시 시도해 주세요.',
          ),
        ),
      );
    } finally {
      _state = state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  void _typePassword(String password) {
    _state = state.copyWith(password: password);
    notifyListeners();
  }
}
