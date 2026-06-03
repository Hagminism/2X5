import 'package:capstone_2026/feature/my_page/reservation_history/domain/model/user_reservation_history_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'reservation_history_event.freezed.dart';

@freezed
sealed class ReservationHistoryEvent with _$ReservationHistoryEvent {
  const factory ReservationHistoryEvent.pop() = PopReservationHistoryScreen;

  const factory ReservationHistoryEvent.push(String location) =
      PushReservationHistoryRoute;

  const factory ReservationHistoryEvent.showSnackBar(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) = ShowReservationHistorySnackBar;

  const factory ReservationHistoryEvent.showReviewBottomSheet({
    required String storeId,
    required String storeName,
    required String reservationId,
    required UserReservationHistoryType reservationType,
  }) = ShowReservationHistoryReviewBottomSheet;
}
