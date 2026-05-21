import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_selection_action.freezed.dart';

@freezed
sealed class TimeSelectionAction with _$TimeSelectionAction {
  const factory TimeSelectionAction.tapBack() = TapBack;

  const factory TimeSelectionAction.tapRetry() = TapRetry;

  const factory TimeSelectionAction.tapSelectUsageOption({
    required int durationMinutes,
  }) = TapSelectUsageOption;

  const factory TimeSelectionAction.tapSubmit() = TapSubmit;
}
