class StoreOperatingHoursValidator {
  static final RegExp _timePattern = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
  static const String _endOfDayTime = '24:00';

  const StoreOperatingHoursValidator();

  bool isValid(Map<String, dynamic> operatingHours) {
    try {
      for (final entry in operatingHours.entries) {
        final dayConfig = (entry.value as Map).cast<String, dynamic>();
        final isOpened = dayConfig['isOpened'];
        final openTime = dayConfig['openTime'];
        final closeTime = dayConfig['closeTime'];
        final breakStartTime = dayConfig['breakStartTime'];
        final breakEndTime = dayConfig['breakEndTime'];

        if (isOpened is! bool) {
          return false;
        }

        if (!isOpened) {
          if (openTime != null ||
              closeTime != null ||
              breakStartTime != null ||
              breakEndTime != null) {
            return false;
          }
          continue;
        }

        if (openTime is! String || closeTime is! String) {
          return false;
        }
        if (!_isValidOpenTime(openTime) || !_isValidCloseTime(closeTime)) {
          return false;
        }
        if (openTime == closeTime) {
          return false;
        }

        final hasBreakStart = breakStartTime != null;
        final hasBreakEnd = breakEndTime != null;
        if (hasBreakStart != hasBreakEnd) {
          return false;
        }
        if (hasBreakStart && hasBreakEnd) {
          if (breakStartTime is! String || breakEndTime is! String) {
            return false;
          }
          if (!_isValidOpenTime(breakStartTime) ||
              !_isValidCloseTime(breakEndTime)) {
            return false;
          }
          if (breakStartTime == breakEndTime) {
            return false;
          }
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _isValidOpenTime(String time) {
    return _timePattern.hasMatch(time);
  }

  bool _isValidCloseTime(String time) {
    return _timePattern.hasMatch(time) || time == _endOfDayTime;
  }
}
