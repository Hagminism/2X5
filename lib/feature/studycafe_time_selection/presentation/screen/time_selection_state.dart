import 'package:capstone_2026/core/domain/model/studycafe/studycafe_usage_option.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_selection_state.freezed.dart';

@freezed
abstract class TimeSelectionState with _$TimeSelectionState {
  const factory TimeSelectionState({
    required String storeId,
    required String seatId,
    required String seatLabel,
    @Default(true) bool isLoadingDetail,
    String? loadError,
    @Default(false) bool seatTakenByOther,
    @Default([]) List<StudyCafeUsageOption> usageOptions,
    int? selectedDurationMinutes,
    @Default(false) bool isSubmitting,
    String? submitError,
  }) = _TimeSelectionState;
}
