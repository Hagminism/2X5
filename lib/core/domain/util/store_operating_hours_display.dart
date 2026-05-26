import 'package:capstone_2026/core/domain/model/enum/week_day.dart';
import 'package:capstone_2026/core/domain/util/format_today_operating_hours.dart';

class StoreOperatingHoursDayLine {
  const StoreOperatingHoursDayLine({
    required this.dayLabel,
    required this.hoursText,
    this.subText,
  });

  final String dayLabel;
  final String hoursText;
  final String? subText;
}

bool hasStructuredStoreOperatingHours(Map<String, dynamic> operatingHours) {
  for (final day in WeekDay.values) {
    if (operatingHours[day.dbKey] is Map<String, dynamic>) {
      return true;
    }
  }
  return false;
}

String? legacyOperatingHoursText(Map<String, dynamic> operatingHours) {
  final text = operatingHours['text']?.toString().trim();
  if (text != null && text.isNotEmpty) {
    return text;
  }
  return null;
}

String resolveOperatingHoursSummary(Map<String, dynamic> operatingHours) {
  final legacy = legacyOperatingHoursText(operatingHours);
  if (legacy != null) {
    return legacy;
  }

  final today = formatTodayOperatingHours(operatingHours);
  if (today.isNotEmpty) {
    return today;
  }

  return '';
}

List<WeekDay> weekDaysStartingFromToday() {
  final all = WeekDay.values;
  final startIndex = DateTime.now().weekday - DateTime.monday;
  return [
    ...all.sublist(startIndex),
    ...all.sublist(0, startIndex),
  ];
}

List<StoreOperatingHoursDayLine> buildWeeklyOperatingHoursLines(
  Map<String, dynamic> operatingHours,
) {
  if (!hasStructuredStoreOperatingHours(operatingHours)) {
    return const [];
  }

  final lines = <StoreOperatingHoursDayLine>[];
  for (final day in weekDaysStartingFromToday()) {
    final dayConfig = operatingHours[day.dbKey];
    if (dayConfig is! Map<String, dynamic>) {
      lines.add(
        StoreOperatingHoursDayLine(
          dayLabel: day.label,
          hoursText: '휴무',
        ),
      );
      continue;
    }

    final isOpened = dayConfig['isOpened'] == true;
    if (!isOpened) {
      lines.add(
        StoreOperatingHoursDayLine(
          dayLabel: day.label,
          hoursText: '휴무',
        ),
      );
      continue;
    }

    final openTime = dayConfig['openTime']?.toString().trim() ?? '';
    final closeTime = dayConfig['closeTime']?.toString().trim() ?? '';
    if (openTime.isEmpty || closeTime.isEmpty) {
      lines.add(
        StoreOperatingHoursDayLine(
          dayLabel: day.label,
          hoursText: '영업시간 미등록',
        ),
      );
      continue;
    }

    final breakStartTime = dayConfig['breakStartTime']?.toString().trim() ?? '';
    final breakEndTime = dayConfig['breakEndTime']?.toString().trim() ?? '';
    final breakSubText = breakStartTime.isNotEmpty && breakEndTime.isNotEmpty
        ? '브레이크 $breakStartTime - $breakEndTime'
        : null;

    lines.add(
      StoreOperatingHoursDayLine(
        dayLabel: day.label,
        hoursText: '$openTime - $closeTime',
        subText: breakSubText,
      ),
    );
  }

  return lines;
}
