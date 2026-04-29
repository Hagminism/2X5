class StoreOperatingHoursValidator {
  static final RegExp _timePattern = RegExp(r'^\d{2}:\d{2}$');

  const StoreOperatingHoursValidator();

  bool isValid(Map<String, dynamic> operatingHours) {
    try {
      for (final entry in operatingHours.entries) {
        final dayConfig = (entry.value as Map).cast<String, dynamic>();
        final isOpened = dayConfig['isOpened'];
        final openTime = dayConfig['openTime'];
        final closeTime = dayConfig['closeTime'];

        if (isOpened is! bool) {
          return false;
        }

        if (!isOpened) {
          if (openTime != null || closeTime != null) {
            return false;
          }
          continue;
        }

        if (openTime is! String || closeTime is! String) {
          return false;
        }
        if (!_timePattern.hasMatch(openTime) || !_timePattern.hasMatch(closeTime)) {
          return false;
        }
        if (openTime == closeTime) {
          return false;
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
