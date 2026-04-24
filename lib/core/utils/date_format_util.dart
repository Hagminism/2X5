String formatDotDate(DateTime date) {
  if (date.millisecondsSinceEpoch == 0) {
    return '';
  }

  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year.$month.$day';
}
