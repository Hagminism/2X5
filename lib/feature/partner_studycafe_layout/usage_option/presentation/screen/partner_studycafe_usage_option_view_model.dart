import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';
import 'dart:async';

import 'package:capstone_2026/core/domain/model/studycafe/studycafe_detail.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_usage_option.dart';
import 'package:capstone_2026/core/domain/repository/studycafe/studycafe_repository.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/usage_option/presentation/screen/partner_studycafe_usage_option_action.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/usage_option/presentation/screen/partner_studycafe_usage_option_event.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/usage_option/presentation/screen/partner_studycafe_usage_option_state.dart';
import 'package:flutter/foundation.dart';

class PartnerStudyCafeUsageOptionViewModel extends ChangeNotifier {
  final StudyCafeRepository _studyCafeRepository;

  PartnerStudyCafeUsageOptionViewModel({
    required StudyCafeRepository studyCafeRepository,
  }) : _studyCafeRepository = studyCafeRepository;

  PartnerStudyCafeUsageOptionState _state =
      const PartnerStudyCafeUsageOptionState();
  PartnerStudyCafeUsageOptionState get state => _state;

  final StreamController<PartnerStudyCafeUsageOptionEvent> _eventController =
      StreamController<PartnerStudyCafeUsageOptionEvent>.broadcast();
  Stream<PartnerStudyCafeUsageOptionEvent> get eventStream =>
      _eventController.stream;

  Future<void> initialize() async {
    _state = state.copyWith(isLoading: true);
    notifyListeners();
    try {
      final detail = await _studyCafeRepository.getMyStoreDetail();
      _state = state.copyWith(
        isLoading: false,
        detailId: detail.id,
        storeId: detail.storeId,
        usageOptions: detail.usageOptions.isEmpty
            ? const [
                StudyCafeUsageOption(
                  durationMinutes: 120,
                  price: 0,
                  isEnabled: true,
                ),
              ]
            : detail.usageOptions,
      );
      notifyListeners();
    } catch (e) {
      _state = state.copyWith(isLoading: false);
      notifyListeners();
      _eventController.add(
        PartnerStudyCafeUsageOptionEvent.showMessage(e.toString()),
      );
    }
  }

  void onAction(PartnerStudyCafeUsageOptionAction action) {
    switch (action) {
      case UsageOptionAdd():
        _state = state.copyWith(
          usageOptions: [
            ...state.usageOptions,
            const StudyCafeUsageOption(
              durationMinutes: 120,
              price: 0,
              isEnabled: true,
            ),
          ],
        );
        notifyListeners();
        break;
      case UsageOptionRemove(:final index):
        if (index < 0 || index >= state.usageOptions.length) {
          return;
        }
        final next = List<StudyCafeUsageOption>.from(state.usageOptions)
          ..removeAt(index);
        _state = state.copyWith(usageOptions: next);
        notifyListeners();
        break;
      case UsageOptionChangeDuration(:final index, :final value):
        final duration =
            int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        _updateUsageOptionAt(
          index,
          (option) => option.copyWith(durationMinutes: duration),
        );
        break;
      case UsageOptionChangePrice(:final index, :final value):
        final price =
            int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        _updateUsageOptionAt(
          index,
          (option) => option.copyWith(price: price),
        );
        break;
      case UsageOptionToggleEnabled(:final index, :final value):
        _updateUsageOptionAt(
          index,
          (option) => option.copyWith(isEnabled: value),
        );
        break;
      case UsageOptionTapSave():
        save();
        break;
    }
  }

  Future<void> save() async {
    if (state.isSaving) {
      return;
    }
    _state = state.copyWith(isSaving: true);
    notifyListeners();
    try {
      final fresh = await _studyCafeRepository.getMyStoreDetail();
      final detail = StudyCafeDetail(
        id: fresh.id,
        storeId: fresh.storeId,
        seats: fresh.seats,
        elements: fresh.elements,
        usageOptions: state.usageOptions,
      );
      final saved = await _studyCafeRepository.saveMyStoreDetail(detail);
      _state = state.copyWith(
        isSaving: false,
        detailId: saved.id,
        storeId: saved.storeId,
        usageOptions: saved.usageOptions,
      );
      notifyListeners();
      _eventController.add(
        const PartnerStudyCafeUsageOptionEvent.showMessage(
          '이용권 설정이 저장되었습니다.',
          variant: AppSnackBarVariant.success,
        ),
      );
    } catch (e) {
      _state = state.copyWith(isSaving: false);
      notifyListeners();
      _eventController.add(
        PartnerStudyCafeUsageOptionEvent.showMessage(e.toString()),
      );
    }
  }

  void _updateUsageOptionAt(
    int index,
    StudyCafeUsageOption Function(StudyCafeUsageOption option) update,
  ) {
    if (index < 0 || index >= state.usageOptions.length) {
      return;
    }
    final next = List<StudyCafeUsageOption>.from(state.usageOptions);
    next[index] = update(next[index]);
    _state = state.copyWith(usageOptions: next);
    notifyListeners();
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
