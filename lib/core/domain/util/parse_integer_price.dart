int parseIntegerPrice(Object? raw, {int fallback = 0}) {
  if (raw == null) {
    return fallback;
  }
  if (raw is int) {
    return raw;
  }
  if (raw is num) {
    return raw.toInt();
  }

  final digits = raw.toString().replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(digits) ?? fallback;
}
