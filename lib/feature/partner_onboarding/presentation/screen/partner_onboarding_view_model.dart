import 'dart:async';

import 'package:capstone_2026/core/domain/model/enum/partner_status.dart';
import 'package:capstone_2026/core/domain/model/enum/user_type.dart';
import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/routing/core/component/user_registration_status_notifier.dart';
import 'package:capstone_2026/feature/partner_onboarding/presentation/screen/partner_onboarding_action.dart';
import 'package:capstone_2026/feature/partner_onboarding/presentation/screen/partner_onboarding_event.dart';
import 'package:capstone_2026/feature/partner_onboarding/presentation/screen/partner_onboarding_state.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class PartnerOnboardingViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FirebaseFunctions _firebaseFunctions;
  final UserRegistrationStatusNotifier _userRegistrationStatusNotifier;

  PartnerOnboardingViewModel({
    required AuthRepository authRepository,
    required FirebaseFunctions firebaseFunctions,
    required UserRegistrationStatusNotifier userRegistrationStatusNotifier,
  }) : _authRepository = authRepository,
       _firebaseFunctions = firebaseFunctions,
       _userRegistrationStatusNotifier = userRegistrationStatusNotifier;

  PartnerOnboardingState _state = const PartnerOnboardingState();

  PartnerOnboardingState get state => _state;

  final StreamController<PartnerOnboardingEvent> _eventController =
      StreamController<PartnerOnboardingEvent>.broadcast();

  Stream<PartnerOnboardingEvent> get eventStream => _eventController.stream;

  void initialize() {
    _syncPartnerStatusFromProfile();
    notifyListeners();
  }

  Future<void> onAction(PartnerOnboardingAction action) async {
    switch (action) {
      case ChangeRepresentativeName():
        _changeRepresentativeName(action.name);
        break;
      case ChangeBusinessNumber():
        _changeBusinessNumber(action.businessNumber);
        break;
      case TapVerifyBusinessNumber():
        await _verifyBusinessNumber();
        break;
      case TapPickOpenedOn():
        _eventController.add(
          PartnerOnboardingEvent.showDatePicker(state.openedOn),
        );
        break;
      case ChangeOpenedOn():
        _changeOpenedOn(action.openedOn);
        break;
      case TapPickLicenseImage():
        _eventController.add(
          const PartnerOnboardingEvent.showMockGalleryPicker(),
        );
        break;
      case ChangeLicenseImageUrl():
        _changeLicenseImageUrl(action.imageUrl);
        break;
      case TapSubmit():
        await _submit();
        break;
      case TapRefreshStatus():
        await _refreshStatus();
        break;
      case TapRetrySubmit():
        _retrySubmit();
        break;
    }
  }

  void _syncPartnerStatusFromProfile() {
    final profile = _userRegistrationStatusNotifier.currentUserProfile;
    final isPartner = profile?.userType == UserType.partner;
    final isPending = isPartner && profile?.partnerStatus == PartnerStatus.pending;
    final isRejected =
        isPartner && profile?.partnerStatus == PartnerStatus.rejected;
    _state = state.copyWith(
      isPending: isPending,
      isRejected: isRejected,
    );
  }

  void _changeRepresentativeName(String name) {
    _state = state.copyWith(representativeName: name);
    notifyListeners();
  }

  void _changeBusinessNumber(String businessNumber) {
    _state = state.copyWith(
      businessNumber: businessNumber,
      isBusinessNumberVerified: false,
    );
    notifyListeners();
  }

  void _changeOpenedOn(DateTime openedOn) {
    _state = state.copyWith(openedOn: openedOn);
    notifyListeners();
  }

  void _changeLicenseImageUrl(String imageUrl) {
    _state = state.copyWith(
      isUploadingLicenseImage: false,
      licenseImageUrl: imageUrl,
    );
    notifyListeners();
  }

  Future<void> _verifyBusinessNumber() async {
    final normalized = _normalizeBusinessNumber(state.businessNumber);
    if (!RegExp(r'^\d{10}$').hasMatch(normalized)) {
      _eventController.add(
        const PartnerOnboardingEvent.showMessage(
          '사업자등록번호는 숫자 10자리로 입력해 주세요.',
        ),
      );
      return;
    }

    _state = state.copyWith(
      isVerifyingBusinessNumber: true,
      isBusinessNumberVerified: false,
    );
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 800));

    _state = state.copyWith(
      isVerifyingBusinessNumber: false,
      isBusinessNumberVerified: true,
      businessNumber: normalized,
    );
    notifyListeners();

    _eventController.add(
      const PartnerOnboardingEvent.showMessage(
        '사업자등록번호 검증이 완료되었습니다. (Mock)',
      ),
    );
  }

  Future<void> submitSelectedMockImage(String selectedImageName) async {
    _state = state.copyWith(isUploadingLicenseImage: true);
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 900));

    final uploadedUrl = 'https://mock-storage.local/license/$selectedImageName';
    _changeLicenseImageUrl(uploadedUrl);
    _eventController.add(
      const PartnerOnboardingEvent.showMessage(
        '등록증 이미지 업로드가 완료되었습니다. (Mock)',
      ),
    );
  }

  Future<void> _submit() async {
    if (!state.canSubmit) return;

    final uid = _authRepository.getCurrentUser()?.uid;
    if (uid == null) {
      _eventController.add(
        const PartnerOnboardingEvent.showMessage(
          '로그인 정보가 만료되었습니다. 다시 로그인해 주세요.',
        ),
      );
      return;
    }

    _state = state.copyWith(isSubmitting: true);
    notifyListeners();

    try {
      final callable = _firebaseFunctions.httpsCallable(
        'submitPartnerVerification',
      );
      final openedOnIsoDate = DateUtils.dateOnly(
        state.openedOn!,
      ).toIso8601String();

      await callable({
        'representativeName': state.representativeName.trim(),
        'businessNumber': state.businessNumber,
        'openedOn': openedOnIsoDate,
        'licenseImageUrl': state.licenseImageUrl,
      });

      await _userRegistrationStatusNotifier.refresh(uid);
      _syncPartnerStatusFromProfile();
      _state = state.copyWith(isSubmitting: false);
      notifyListeners();
      _eventController.add(
        const PartnerOnboardingEvent.showMessage(
          '사업자 인증 정보가 제출되었습니다. 심사를 기다려 주세요.',
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      _state = state.copyWith(isSubmitting: false);
      notifyListeners();
      _eventController.add(
        PartnerOnboardingEvent.showMessage(
          e.message ?? '제출 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.',
        ),
      );
    } catch (_) {
      _state = state.copyWith(isSubmitting: false);
      notifyListeners();
      _eventController.add(
        const PartnerOnboardingEvent.showMessage(
          '제출 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.',
        ),
      );
    }
  }

  String _normalizeBusinessNumber(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _refreshStatus() async {
    final uid = _authRepository.getCurrentUser()?.uid;
    if (uid == null) {
      _eventController.add(
        const PartnerOnboardingEvent.showMessage(
          '로그인 정보가 만료되었습니다. 다시 로그인해 주세요.',
        ),
      );
      return;
    }

    _state = state.copyWith(isRefreshingStatus: true);
    notifyListeners();

    await _userRegistrationStatusNotifier.refresh(uid);
    _syncPartnerStatusFromProfile();

    _state = state.copyWith(isRefreshingStatus: false);
    notifyListeners();
  }

  void _retrySubmit() {
    _state = state.copyWith(
      isRejected: false,
      representativeName: '',
      businessNumber: '',
      openedOn: null,
      licenseImageUrl: null,
      isBusinessNumberVerified: false,
      isVerifyingBusinessNumber: false,
      isUploadingLicenseImage: false,
      isSubmitting: false,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
