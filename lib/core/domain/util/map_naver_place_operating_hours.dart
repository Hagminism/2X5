import 'package:capstone_2026/core/domain/model/enum/week_day.dart';
import 'package:capstone_2026/core/domain/validator/store_operating_hours_validator.dart';

const Map<String, String> _naverDayLabelToDbKey = {
  '월': 'monday',
  '화': 'tuesday',
  '수': 'wednesday',
  '목': 'thursday',
  '금': 'friday',
  '토': 'saturday',
  '일': 'sunday',
};

const int _maxWeeklyHoursEntries = 7;

/// 프록시 `/api/place/{id}/hours` 응답을 `stores.operating_hours` 형식으로 변환합니다.
Map<String, dynamic>? mapNaverWeeklyHoursToStoreOperatingHours(
  Map<String, dynamic>? payload,
) {
  if (payload == null) {
    return null;
  }

  final weeklyRaw = payload['weeklyHours'];
  if (weeklyRaw is! List || weeklyRaw.isEmpty) {
    return null;
  }

  final limitedWeeklyRaw = weeklyRaw.take(_maxWeeklyHoursEntries);
  final result = <String, dynamic>{};

  for (final entry in limitedWeeklyRaw) {
    if (entry is! Map) {
      continue;
    }

    final dayLabel = _parseDayLabel(entry['day']?.toString() ?? '');
    if (dayLabel.isEmpty) {
      continue;
    }

    final start = _normalizeTime(entry['start']?.toString());
    final end = _normalizeTime(entry['end']?.toString());
    final breakStart = _normalizeTime(
      entry['breakStart']?.toString() ?? entry['breakStartTime']?.toString(),
    );
    final breakEnd = _normalizeTime(
      entry['breakEnd']?.toString() ?? entry['breakEndTime']?.toString(),
    );

    final targetDbKeys = dayLabel == '매일'
        ? WeekDay.values.map((d) => d.dbKey).toList()
        : [
            if (_naverDayLabelToDbKey.containsKey(dayLabel))
              _naverDayLabelToDbKey[dayLabel]!,
          ];

    if (targetDbKeys.isEmpty) {
      continue;
    }

    final dayConfig = _buildDayConfig(
      start: start,
      end: end,
      breakStart: breakStart,
      breakEnd: breakEnd,
    );
    for (final dbKey in targetDbKeys) {
      result[dbKey] = dayConfig;
    }
  }

  if (result.isEmpty) {
    return null;
  }

  // API에 없는 요일은 휴무로 간주 (확장 목록·오늘 휴무 표시 일관성)
  for (final day in WeekDay.values) {
    result.putIfAbsent(day.dbKey, () => {'isOpened': false});
  }

  const validator = StoreOperatingHoursValidator();
  if (!validator.isValid(result)) {
    return null;
  }

  return result;
}

String _parseDayLabel(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return '';
  }

  return trimmed.replaceFirst(RegExp(r'\([^)]*\)'), '').trim();
}

Map<String, dynamic> _buildDayConfig({
  required String? start,
  required String? end,
  required String? breakStart,
  required String? breakEnd,
}) {
  if (start != null &&
      end != null &&
      start.isNotEmpty &&
      end.isNotEmpty) {
    final config = <String, dynamic>{
      'isOpened': true,
      'openTime': start,
      'closeTime': end,
    };

    if (breakStart != null &&
        breakEnd != null &&
        breakStart.isNotEmpty &&
        breakEnd.isNotEmpty) {
      config['breakStartTime'] = breakStart;
      config['breakEndTime'] = breakEnd;
    }

    return config;
  }

  return {'isOpened': false};
}

String? _normalizeTime(String? raw) {
  final trimmed = raw?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  if (trimmed.toLowerCase() == 'null') {
    return null;
  }

  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(trimmed);
  if (match == null) {
    return trimmed;
  }

  final hour = int.tryParse(match.group(1)!);
  final minute = match.group(2)!;
  if (hour == null || minute.length != 2) {
    return trimmed;
  }

  if (hour == 24) {
    return minute == '00' ? '24:00' : null;
  }
  if (hour < 0 || hour > 23) {
    return null;
  }

  return '${hour.toString().padLeft(2, '0')}:$minute';
}
