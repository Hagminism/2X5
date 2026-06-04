const int reservationCustomerRequestMaxLength = 200;

/// 예약 요구사항(선택). 빈 문자열은 null로 정규화한다.
String? normalizeReservationCustomerRequest(String? raw) {
  if (raw == null) {
    return null;
  }
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  if (trimmed.length <= reservationCustomerRequestMaxLength) {
    return trimmed;
  }
  return trimmed.substring(0, reservationCustomerRequestMaxLength);
}

String? customerRequestForCallable(String? raw) {
  return normalizeReservationCustomerRequest(raw);
}
