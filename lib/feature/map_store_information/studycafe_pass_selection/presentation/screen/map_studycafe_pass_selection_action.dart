import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_studycafe_pass_selection_action.freezed.dart';

@freezed
sealed class MapStudycafePassSelectionAction
    with _$MapStudycafePassSelectionAction {
  const factory MapStudycafePassSelectionAction.tapBack() =
      MapStudycafePassTapBack;

  const factory MapStudycafePassSelectionAction.tapRetry() =
      MapStudycafePassTapRetry;

  const factory MapStudycafePassSelectionAction.tapSelectUsageOption({
    required int durationMinutes,
  }) = MapStudycafePassTapSelectUsageOption;

  const factory MapStudycafePassSelectionAction.tapSubmit() =
      MapStudycafePassTapSubmit;
}
