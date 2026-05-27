enum UserReservationHistoryType {
  restaurant,
  studyCafe,
  salon
  ;

  String get label => switch (this) {
    UserReservationHistoryType.restaurant => '식당',
    UserReservationHistoryType.studyCafe => '스터디카페',
    UserReservationHistoryType.salon => '미용실',
  };
}
