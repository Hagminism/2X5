import 'package:capstone_2026/core/domain/model/studycafe/studycafe_usage_option.dart';

String timeSelectionUsageOptionTitle(StudyCafeUsageOption option) {
  final minutes = option.durationMinutes;
  if (minutes <= 0) {
    return '이용권';
  }
  if (minutes % 60 == 0) {
    final hours = minutes ~/ 60;
    return '$hours시간 이용권';
  }
  return '$minutes분 이용권';
}

String timeSelectionUsageOptionPriceLabel(StudyCafeUsageOption option) {
  return '${option.price}원';
}
