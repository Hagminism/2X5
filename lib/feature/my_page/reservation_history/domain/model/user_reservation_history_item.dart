import 'package:capstone_2026/core/domain/model/enum/reservation_status.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/domain/model/user_reservation_history_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_reservation_history_item.freezed.dart';

@freezed
abstract class UserReservationHistoryItem with _$UserReservationHistoryItem {
  const factory UserReservationHistoryItem({
    required String id,
    required String storeId,
    required String storeName,
    required String categoryLabel,
    required UserReservationHistoryType type,
    required DateTime scheduledAt,
    required String summary,
    required ReservationStatus status,
  }) = _UserReservationHistoryItem;
}
