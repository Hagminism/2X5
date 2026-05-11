import 'package:capstone_2026/feature/stamp/domain/model/store_stamp_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stamp_history_state.freezed.dart';

@freezed
abstract class StampHistoryState with _$StampHistoryState {
  const factory StampHistoryState({
    @Default(false) bool isLoading,
    @Default(<StoreStampStatus>[]) List<StoreStampStatus> stampStatuses,
  }) = _StampHistoryState;
}
