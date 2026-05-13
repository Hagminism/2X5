import 'package:capstone_2026/core/domain/model/studycafe/studycafe_usage_option.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_studycafe_usage_option_state.freezed.dart';

@freezed
abstract class PartnerStudyCafeUsageOptionState
    with _$PartnerStudyCafeUsageOptionState {
  const factory PartnerStudyCafeUsageOptionState({
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    @Default('') String detailId,
    @Default('') String storeId,
    @Default(<StudyCafeUsageOption>[]) List<StudyCafeUsageOption> usageOptions,
  }) = _PartnerStudyCafeUsageOptionState;
}
