import 'dart:async';

import 'package:capstone_2026/core/domain/model/enum/partner_status.dart';
import 'package:capstone_2026/core/domain/model/enum/user_type.dart';
import 'package:capstone_2026/core/routing/core/component/user_registration_status_notifier.dart';
import 'package:capstone_2026/feature/admin_onboarding/presentation/screen/admin_onboarding_action.dart';
import 'package:capstone_2026/feature/admin_onboarding/presentation/screen/admin_onboarding_event.dart';
import 'package:capstone_2026/feature/admin_onboarding/presentation/screen/admin_onboarding_state.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminOnboardingViewModel extends ChangeNotifier {
  final SupabaseClient _supabaseClient;
  final UserRegistrationStatusNotifier _userRegistrationStatusNotifier;

  AdminOnboardingViewModel({
    required SupabaseClient supabaseClient,
    required UserRegistrationStatusNotifier userRegistrationStatusNotifier,
  }) : _supabaseClient = supabaseClient,
       _userRegistrationStatusNotifier = userRegistrationStatusNotifier;

  AdminOnboardingState _state = const AdminOnboardingState();

  AdminOnboardingState get state => _state;

  final StreamController<AdminOnboardingEvent> _eventController =
      StreamController<AdminOnboardingEvent>.broadcast();

  Stream<AdminOnboardingEvent> get eventStream => _eventController.stream;

  void initialize() {
    final profile = _userRegistrationStatusNotifier.currentUserProfile;
    final isPending = profile?.userType == UserType.partner &&
        profile?.partnerStatus == PartnerStatus.pending;
    _state = state.copyWith(isPending: isPending);
    notifyListeners();
  }

  Future<void> onAction(AdminOnboardingAction action) async {
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
        _eventController.add(AdminOnboardingEvent.showDatePicker(state.openedOn));
        break;
      case ChangeOpenedOn():
        _changeOpenedOn(action.openedOn);
        break;
      case TapPickLicenseImage():
        _eventController.add(const AdminOnboardingEvent.showMockGalleryPicker());
        break;
      case ChangeLicenseImageUrl():
        _changeLicenseImageUrl(action.imageUrl);
        break;
      case TapSubmit():
        await _submit();
        break;
    }
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
        const AdminOnboardingEvent.showMessage(
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
      const AdminOnboardingEvent.showMessage(
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
      const AdminOnboardingEvent.showMessage(
        '등록증 이미지 업로드가 완료되었습니다. (Mock)',
      ),
    );
  }

  Future<void> _submit() async {
    if (!state.canSubmit) return;

    final uid = _supabaseClient.auth.currentUser?.id;
    if (uid == null) {
      _eventController.add(
        const AdminOnboardingEvent.showMessage(
          '로그인 정보가 만료되었습니다. 다시 로그인해 주세요.',
        ),
      );
      return;
    }

    _state = state.copyWith(isSubmitting: true);
    notifyListeners();

    try {
      await _supabaseClient
          .from('users')
          .update({'partner_status': PartnerStatus.pending.name}).eq('id', uid);
      await _userRegistrationStatusNotifier.refresh(uid);
      _state = state.copyWith(isPending: true, isSubmitting: false);
      notifyListeners();
      _eventController.add(
        const AdminOnboardingEvent.showMessage(
          '사업자 인증 정보가 제출되었습니다. 심사를 기다려 주세요.',
        ),
      );
    } catch (_) {
      _state = state.copyWith(isSubmitting: false);
      notifyListeners();
      _eventController.add(
        const AdminOnboardingEvent.showMessage(
          '제출 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.',
        ),
      );
    }
  }

  String _normalizeBusinessNumber(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
