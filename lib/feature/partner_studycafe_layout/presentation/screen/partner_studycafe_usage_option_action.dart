import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_studycafe_usage_option_action.freezed.dart';

@freezed
sealed class PartnerStudyCafeUsageOptionAction
    with _$PartnerStudyCafeUsageOptionAction {
  const factory PartnerStudyCafeUsageOptionAction.addUsageOption() =
      UsageOptionAdd;

  const factory PartnerStudyCafeUsageOptionAction.removeUsageOption(
    int index,
  ) = UsageOptionRemove;

  const factory PartnerStudyCafeUsageOptionAction.changeUsageOptionDuration({
    required int index,
    required String value,
  }) = UsageOptionChangeDuration;

  const factory PartnerStudyCafeUsageOptionAction.changeUsageOptionPrice({
    required int index,
    required String value,
  }) = UsageOptionChangePrice;

  const factory PartnerStudyCafeUsageOptionAction.toggleUsageOptionEnabled({
    required int index,
    required bool value,
  }) = UsageOptionToggleEnabled;

  const factory PartnerStudyCafeUsageOptionAction.tapSave() =
      UsageOptionTapSave;
}
