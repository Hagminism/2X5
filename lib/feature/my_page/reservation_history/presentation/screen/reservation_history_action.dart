import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation_history_action.freezed.dart';

@freezed
sealed class ReservationHistoryAction with _$ReservationHistoryAction {
  const factory ReservationHistoryAction.tapBack() = TapReservationHistoryBack;

  const factory ReservationHistoryAction.tapReservationItem({
    required String storeId,
  }) = TapReservationHistoryItem;

  const factory ReservationHistoryAction.tapReview({
    required String storeId,
    required String storeName,
    required String reservationId,
  }) = TapReservationHistoryReview;

  const factory ReservationHistoryAction.submitReview({
    required String storeId,
    required String storeName,
    required String reservationId,
    required ReviewWriteResult reviewResult,
  }) = SubmitReservationHistoryReview;
}
