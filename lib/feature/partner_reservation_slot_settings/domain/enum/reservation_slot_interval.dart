enum ReservationSlotInterval {
  minutes30(30, '30분'),
  minutes60(60, '60분');

  final int minutes;
  final String label;

  const ReservationSlotInterval(this.minutes, this.label);
}
