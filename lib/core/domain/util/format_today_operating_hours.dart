String formatTodayOperatingHours(Map<String, dynamic> operatingHours) {
  if (operatingHours.isEmpty) {
    return '';
  }

  final weekdayKeys = <int, List<String>>{
    DateTime.monday: ['monday', 'mon'],
    DateTime.tuesday: ['tuesday', 'tue'],
    DateTime.wednesday: ['wednesday', 'wed'],
    DateTime.thursday: ['thursday', 'thu'],
    DateTime.friday: ['friday', 'fri'],
    DateTime.saturday: ['saturday', 'sat'],
    DateTime.sunday: ['sunday', 'sun'],
  };

  for (final key in weekdayKeys[DateTime.now().weekday] ?? const []) {
    final dayConfig = operatingHours[key];
    if (dayConfig is! Map<String, dynamic>) {
      continue;
    }

    final isOpened = dayConfig['isOpened'] == true;
    if (!isOpened) {
      return '오늘 휴무';
    }

    final openTime = dayConfig['openTime']?.toString().trim() ?? '';
    final closeTime = dayConfig['closeTime']?.toString().trim() ?? '';
    if (openTime.isNotEmpty && closeTime.isNotEmpty) {
      return '오늘 $openTime ~ $closeTime 영업';
    }
  }

  return '';
}
