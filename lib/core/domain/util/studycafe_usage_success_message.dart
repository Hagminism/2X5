import 'package:capstone_2026/core/domain/model/studycafe/studycafe_usage_option.dart';

String studycafeUsageSuccessMessage({
  required String seatLabel,
  required StudyCafeUsageOption selected,
}) {
  final hours = selected.durationMinutes % 60 == 0
      ? selected.durationMinutes ~/ 60
      : null;

  if (hours != null) {
    return '$seatLabel번 좌석을 $hours시간 이용합니다.';
  }
  return '$seatLabel번 좌석을 ${selected.durationMinutes}분 이용합니다.';
}
