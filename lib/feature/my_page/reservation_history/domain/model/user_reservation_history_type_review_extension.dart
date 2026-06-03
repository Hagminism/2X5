import 'package:capstone_2026/core/domain/model/review/review_reservation_ref.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/domain/model/user_reservation_history_type.dart';

extension UserReservationHistoryTypeReviewExtension
    on UserReservationHistoryType {
  ReviewReservationSource get reviewReservationSource => switch (this) {
    UserReservationHistoryType.restaurant =>
      ReviewReservationSource.restaurant,
    UserReservationHistoryType.studyCafe => ReviewReservationSource.studyCafe,
    UserReservationHistoryType.salon => ReviewReservationSource.salon,
  };
}
