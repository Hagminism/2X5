import 'package:capstone_2026/feature/my_page/reservation_history/domain/model/user_reservation_history_type.dart';
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
    required UserReservationHistoryType reservationType,
  }) = TapReservationHistoryReview;
}
