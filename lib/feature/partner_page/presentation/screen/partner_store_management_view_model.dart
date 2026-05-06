import 'dart:async';

import 'package:capstone_2026/core/domain/model/store/store.dart';
import 'package:capstone_2026/core/domain/repository/owner_verification/owner_verification_repository.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_action.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_event.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PartnerStoreManagementViewModel extends ChangeNotifier {
  final OwnerVerificationRepository _ownerVerificationRepository;
  final StoreRepository _storeRepository;
  Store? _myStore;
  bool _initialized = false;

  PartnerStoreManagementViewModel({
    required OwnerVerificationRepository ownerVerificationRepository,
    required StoreRepository storeRepository,
  }) : _ownerVerificationRepository = ownerVerificationRepository,
       _storeRepository = storeRepository;

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
      case ChangeStoreContact():
        _state = state.copyWith(storeContact: action.value);
        notifyListeners();
        break;
      case ToggleDayOpened():
        _updateDayConfig(
          day: action.day,
          update: (current) => {
            ...current,
            'isOpened': action.isOpened,
            'openTime': action.isOpened ? current['openTime'] : null,
            'closeTime': action.isOpened ? current['closeTime'] : null,
          },
        );
        notifyListeners();
        break;
      case ChangeDayOpenTime():
        _updateDayConfig(
          day: action.day,
          update: (current) => {
            ...current,
            'openTime': action.value,
          },
        );
        notifyListeners();
        break;
      case ChangeDayCloseTime():
        _updateDayConfig(
          day: action.day,
          update: (current) => {
            ...current,
            'closeTime': action.value,
          },
        );
        notifyListeners();
        break;
      case TapSubmit():
        _submit();
        break;
    }
  }

  Future<void> initialize() async {
    if (_initialized || state.isLoadingInitialData) {
      return;
    }
    _initialized = true;

    _state = state.copyWith(isLoadingInitialData: true);
    notifyListeners();

    try {
      final businessNumberFuture = _ownerVerificationRepository
          .getMyApprovedBusinessNumber();
      final myStoreFuture = _storeRepository.getMyStore();
      final businessNumber = await businessNumberFuture;
      _myStore = await myStoreFuture;

      if (_myStore != null) {
        final operatingHours = _normalizeOperatingHours(
          _myStore!.operatingHours,
        );
        _state = state.copyWith(
          isLoadingInitialData: false,
          isFormVisible: true,
          isEditMode: true,
          storeName: _myStore!.name,
          category: _myStore!.category,
          businessNumber: _myStore!.businessNumber,
          address: _myStore!.address,
          latitude: _myStore!.latitude.toStringAsFixed(7),
          longitude: _myStore!.longitude.toStringAsFixed(7),
          storeContact: _myStore!.contact,
          operatingHours: operatingHours,
        );
        notifyListeners();
        return;
      }

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

    try {
      final isCreate = _myStore == null;
      final latitude = double.parse(state.latitude);
      final longitude = double.parse(state.longitude);
      final payload = Store(
        id: _myStore?.id ?? '',
        ownerId: _myStore?.ownerId ?? '',
        name: state.storeName.trim(),
        category: state.category.trim(),
        businessNumber: state.businessNumber.trim(),
        address: state.address.trim(),
        latitude: latitude,
        longitude: longitude,
        contact: state.storeContact.trim(),
        naverPlaceId: _myStore?.naverPlaceId,
        operatingHours: state.operatingHours,
      );

      final savedStore = _myStore == null
          ? await _storeRepository.createMyStore(payload)
          : await _storeRepository.updateMyStore(payload);
      _myStore = savedStore;

      _state = state.copyWith(
        isSubmitting: false,
        isEditMode: true,
        isFormVisible: true,
      );
      notifyListeners();

      _eventController.add(
        PartnerStoreManagementEvent.showMessage(
          isCreate ? '업장 등록이 완료되었습니다.' : '업장 정보가 수정되었습니다.',
        ),
      );
    } catch (e) {
      _state = state.copyWith(isSubmitting: false);
      notifyListeners();
      print('${state.operatingHours}');
      print('error: $e');
      _eventController.add(
        PartnerStoreManagementEvent.showMessage(
          e is StateError || e is ArgumentError
              ? e
                    .toString()
                    .replaceFirst('Bad state: ', '')
                    .replaceFirst('Invalid argument(s): ', '')
              : '업장 정보 저장 중 오류가 발생했습니다.',
        ),
      );
    }
  }

  void _updateDayConfig({
    required String day,
    required Map<String, dynamic> Function(Map<String, dynamic> current) update,
  }) {
    final next = Map<String, Map<String, dynamic>>.from(state.operatingHours);
    final current = Map<String, dynamic>.from(next[day] ?? const {});
    next[day] = update(current);
    _state = state.copyWith(operatingHours: next);
  }

  Map<String, Map<String, dynamic>> _normalizeOperatingHours(
    Map<String, dynamic> raw,
  ) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final normalized = <String, Map<String, dynamic>>{};
    for (final day in days) {
      final current = raw[day];
      if (current is Map) {
        normalized[day] = {
          'isOpened': current['isOpened'] == true,
          'openTime': current['openTime'],
          'closeTime': current['closeTime'],
        };
      } else {
        normalized[day] = {
          'isOpened': true,
          'openTime': null,
          'closeTime': null,
        };
      }
    }
    return normalized;
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
