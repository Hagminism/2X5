import 'dart:async';

import 'package:capstone_2026/core/domain/repository/owner_verification/owner_verification_repository.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_action.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_event.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PartnerStoreManagementViewModel extends ChangeNotifier {
  final OwnerVerificationRepository _ownerVerificationRepository;

  PartnerStoreManagementViewModel({
    required OwnerVerificationRepository ownerVerificationRepository,
  }) : _ownerVerificationRepository = ownerVerificationRepository;

  PartnerStoreManagementState _state = const PartnerStoreManagementState();

  PartnerStoreManagementState get state => _state;

  final StreamController<PartnerStoreManagementEvent> _eventController =
      StreamController<PartnerStoreManagementEvent>.broadcast();

  Stream<PartnerStoreManagementEvent> get eventStream =>
      _eventController.stream;

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
      case TapAddressSearch():
        _eventController.add(
          const PartnerStoreManagementEvent.openAddressSearch(),
        );
        break;
      case SelectAddressSearchResult():
        debugPrint(
          '[AddressFlow] apply result address=${action.result.address}, '
          'lat=${action.result.latitude}, lng=${action.result.longitude}',
        );
        _state = state.copyWith(
          address: action.result.address,
          latitude: action.result.latitude.toStringAsFixed(7),
          longitude: action.result.longitude.toStringAsFixed(7),
        );
        debugPrint(
          '[AddressFlow] state updated address=${_state.address}, '
          'lat=${_state.latitude}, lng=${_state.longitude}',
        );
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

  Future<void> initialize() async {
    if (state.isLoadingInitialData || state.businessNumber.trim().isNotEmpty) {
      return;
    }

    _state = state.copyWith(isLoadingInitialData: true);
    notifyListeners();

    try {
      final businessNumber = await _ownerVerificationRepository
          .getMyApprovedBusinessNumber();

      if (businessNumber == null || businessNumber.isEmpty) {
        _state = state.copyWith(isLoadingInitialData: false);
        notifyListeners();
        _eventController.add(
          const PartnerStoreManagementEvent.showMessage(
            '승인된 사업자등록번호 정보를 찾을 수 없습니다. 관리자에게 문의해 주세요.',
          ),
        );
        return;
      }

      _state = state.copyWith(
        isLoadingInitialData: false,
        businessNumber: businessNumber,
      );
      notifyListeners();
    } catch (_) {
      _state = state.copyWith(isLoadingInitialData: false);
      notifyListeners();
      _eventController.add(
        const PartnerStoreManagementEvent.showMessage(
          '사업자등록번호를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.',
        ),
      );
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
