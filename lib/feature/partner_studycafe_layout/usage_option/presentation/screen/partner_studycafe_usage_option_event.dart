import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_studycafe_usage_option_event.freezed.dart';

@freezed
sealed class PartnerStudyCafeUsageOptionEvent
    with _$PartnerStudyCafeUsageOptionEvent {
  const factory PartnerStudyCafeUsageOptionEvent.showMessage(String message) =
      UsageOptionShowMessage;
}
