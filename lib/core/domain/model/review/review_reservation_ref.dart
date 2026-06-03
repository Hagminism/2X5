enum ReviewReservationSource {
  restaurant,
  studyCafe,
  salon;

  String get reservationColumn => switch (this) {
    ReviewReservationSource.restaurant => 'restaurant_reservation_id',
    ReviewReservationSource.studyCafe => 'studycafe_reservation_id',
    ReviewReservationSource.salon => 'salon_reservation_id',
  };

  String get reservationTable => switch (this) {
    ReviewReservationSource.restaurant => 'reservations',
    ReviewReservationSource.studyCafe => 'studycafe_reservations',
    ReviewReservationSource.salon => 'salon_reservations',
  };
}

class ReviewReservationRef {
  const ReviewReservationRef({
    required this.source,
    required this.reservationId,
  });

  final ReviewReservationSource source;
  final String reservationId;
}
