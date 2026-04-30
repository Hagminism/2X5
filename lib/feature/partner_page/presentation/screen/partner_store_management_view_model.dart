import 'dart:async';

import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_action.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_event.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_state.dart';
import 'package:flutter/material.dart';

class PartnerStoreManagementViewModel extends ChangeNotifier {
  PartnerStoreManagementState _state = const PartnerStoreManagementState();

  PartnerStoreManagementState get state => _state;

  final StreamController<PartnerStoreManagementEvent> _eventController =
      StreamController<PartnerStoreManagementEvent>.broadcast();

  Stream<PartnerStoreManagementEvent> get eventStream => _eventController.stream;

  void onAction(PartnerStoreManagementAction action) {
    switch (action) {
      case TapShowRegistrationForm():
        _state = state.copyWith(isFormVisible: true);
        notifyListeners();
        break;
      case ChangeStoreName():
        _state = state.copyWith(storeName: action.value);
        notifyListeners();
        break;
      case ChangeCategory():
        _state = state.copyWith(category: action.value);
        notifyListeners();
        break;
      case ChangeBusinessNumber():
        _state = state.copyWith(businessNumber: action.value);
        notifyListeners();
        break;
      case ChangeAddress():
        _state = state.copyWith(address: action.value);
        notifyListeners();
        break;
      case ChangeLatitude():
        _state = state.copyWith(latitude: action.value);
        notifyListeners();
        break;
      case ChangeLongitude():
        _state = state.copyWith(longitude: action.value);
        notifyListeners();
        break;
      case ChangeStoreContact():
        _state = state.copyWith(storeContact: action.value);
        notifyListeners();
        break;
      case ChangeOperatingHours():
        _state = state.copyWith(operatingHours: action.value);
        notifyListeners();
        break;
      case TapSubmit():
        _submit();
        break;
    }
  }

  Future<void> _submit() async {
    if (!state.canSubmit) {
      _eventController.add(
        const PartnerStoreManagementEvent.showMessage(
          '필수 항목을 모두 입력해 주세요.',
        ),
      );
      return;
    }

    _state = state.copyWith(isSubmitting: true);
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 300));

    _state = state.copyWith(
      isSubmitting: false,
      isSubmitted: true,
    );
    notifyListeners();

    _eventController.add(
      const PartnerStoreManagementEvent.showMessage('업장 등록 요청이 접수되었습니다.'),
    );
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
