enum ReservationCongestionLevel {
  relaxed('여유'),
  normal('보통'),
  busy('혼잡'),
  saturated('포화'),
  closed('마감')
  ;

  final String label;

  const ReservationCongestionLevel(this.label);
}
