import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'partner_studycafe_usage_option_event.freezed.dart';

@freezed
sealed class PartnerStudyCafeUsageOptionEvent
    with _$PartnerStudyCafeUsageOptionEvent {
  const factory PartnerStudyCafeUsageOptionEvent.showMessage(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) = UsageOptionShowMessage;
}
