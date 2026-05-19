import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_studycafe_pass_selection_action.freezed.dart';

@freezed
sealed class SearchStudycafePassSelectionAction
    with _$SearchStudycafePassSelectionAction {
  const factory SearchStudycafePassSelectionAction.tapBack() =
      SearchStudycafePassTapBack;

  const factory SearchStudycafePassSelectionAction.tapRetry() =
      SearchStudycafePassTapRetry;

  const factory SearchStudycafePassSelectionAction.tapSelectUsageOption({
    required int durationMinutes,
  }) = SearchStudycafePassTapSelectUsageOption;

  const factory SearchStudycafePassSelectionAction.tapSubmit() =
      SearchStudycafePassTapSubmit;
}
