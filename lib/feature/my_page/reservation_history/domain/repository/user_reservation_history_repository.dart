import 'package:capstone_2026/feature/my_page/reservation_history/domain/model/user_reservation_history_item.dart';

abstract interface class UserReservationHistoryRepository {
  Future<List<UserReservationHistoryItem>> fetchUserReservationHistory({
    required String userId,
  });
}
