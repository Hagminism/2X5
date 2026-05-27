import 'package:capstone_2026/core/domain/model/enum/week_day.dart';
import 'package:capstone_2026/core/domain/model/reservation/reservation.dart';
import 'package:capstone_2026/core/domain/model/reservation/restaurant_time_slot.dart';
import 'package:capstone_2026/core/domain/model/reservation/store_reservation_slot_default.dart';
import 'package:capstone_2026/core/domain/model/reservation/store_schedule_exception.dart';
import 'package:capstone_2026/core/domain/model/store/store.dart';
import 'package:capstone_2026/core/util/salon_booking_time.dart';

abstract final class RestaurantBookingSlot {
  static const int _fallbackMaxGuestCount = 4;

  static List<RestaurantTimeSlot> buildSlotsForDate({
    required Store store,
    required DateTime targetDate,
    required List<StoreReservationSlotDefault> slotDefaults,
    StoreScheduleException? scheduleException,
    required List<Reservation> reservations,
    DateTime? now,
  }) {
    final calendarDate = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    if (scheduleException?.isClosed == true) {
      return const [];
    }

    final dayKey = _dayKeyForDate(calendarDate);
    final dayConfig = store.operatingHours[dayKey];
    if (dayConfig is! Map<String, dynamic>) {
      return const [];
    }

    final isOpened = dayConfig['isOpened'] == true;
    if (!isOpened) {
      return const [];
    }

    final openClose = _resolveOpenClose(
      dayConfig: dayConfig,
      scheduleException: scheduleException,
    );
    if (openClose == null) {
      return const [];
    }

    final slotMinutes = store.reservationSlotMinutes;
    final times = _enumerateSlotTimes(
      openMinutes: openClose.openMinutes,
      closeMinutes: openClose.closeMinutes,
      slotMinutes: slotMinutes,
    );

    final defaultsByTime = {
      for (final slotDefault in slotDefaults) slotDefault.slotTime: slotDefault,
    };
    final overridesByTime = {
      for (final override in scheduleException?.slotOverrides ?? [])
        override.time: override,
    };
    final reservedByTime = _reservedGuestCountByTime(
      reservations: reservations,
      targetDate: calendarDate,
    );

    final current = now ?? DateTime.now();
    final today = SalonBookingTime.seoulTodayCalendar();
    final isToday = calendarDate.year == today.year &&
        calendarDate.month == today.month &&
        calendarDate.day == today.day;
    final nowMinutes = isToday ? _seoulNowMinutes(current) : null;

    return times.map((time) {
      final slotDefault = defaultsByTime[time];
      final override = overridesByTime[time];
      var maxGuestCount = slotDefault?.maxGuestCount ?? _fallbackMaxGuestCount;
      var isOpen = slotDefault?.isOpen ?? true;

      if (override?.maxGuestCount != null) {
        maxGuestCount = override!.maxGuestCount!;
      }
      if (override?.isOpen != null) {
        isOpen = override!.isOpen!;
      }

      final reservedGuestCount = reservedByTime[time] ?? 0;
      final slotMinutesValue = _timeToMinutes(time);
      final isPast = isToday &&
          nowMinutes != null &&
          slotMinutesValue <= nowMinutes;
      final remaining = (maxGuestCount - reservedGuestCount).clamp(0, 9999);
      final isSelectable = isOpen && !isPast && remaining > 0;

      return RestaurantTimeSlot(
        time: time,
        maxGuestCount: maxGuestCount,
        reservedGuestCount: reservedGuestCount,
        isOpen: isOpen,
        isSelectable: isSelectable,
      );
    }).toList();
  }

  static bool isDateClosed({
    required Store store,
    required DateTime targetDate,
    StoreScheduleException? scheduleException,
  }) {
    if (scheduleException?.isClosed == true) {
      return true;
    }

    return isDateClosedFromOperatingHours(
      operatingHours: store.operatingHours,
      targetDate: targetDate,
    );
  }

  static bool isDateClosedFromOperatingHours({
    required Map<String, dynamic> operatingHours,
    required DateTime targetDate,
  }) {
    final dayKey = _dayKeyForDate(
      DateTime(targetDate.year, targetDate.month, targetDate.day),
    );
    final dayConfig = operatingHours[dayKey];
    if (dayConfig is! Map<String, dynamic>) {
      return true;
    }

    return dayConfig['isOpened'] != true;
  }

  static String _dayKeyForDate(DateTime date) {
    final dow = SalonBookingTime.seoulPostgresDayOfWeek(
      date.year,
      date.month,
      date.day,
    );
    return switch (dow) {
      0 => WeekDay.sunday.dbKey,
      1 => WeekDay.monday.dbKey,
      2 => WeekDay.tuesday.dbKey,
      3 => WeekDay.wednesday.dbKey,
      4 => WeekDay.thursday.dbKey,
      5 => WeekDay.friday.dbKey,
      _ => WeekDay.saturday.dbKey,
    };
  }

  static ({int openMinutes, int closeMinutes})? _resolveOpenClose({
    required Map<String, dynamic> dayConfig,
    StoreScheduleException? scheduleException,
  }) {
    if (scheduleException?.openTime != null &&
        scheduleException?.closeTime != null) {
      final openMinutes = _timeToMinutes(scheduleException!.openTime!);
      final closeMinutes = _timeToMinutes(scheduleException.closeTime!);
      if (openMinutes < 0 || closeMinutes <= openMinutes) {
        return null;
      }
      return (openMinutes: openMinutes, closeMinutes: closeMinutes);
    }

    final openTime = _normalizeTimeString(dayConfig['openTime']);
    final closeTime = _normalizeTimeString(dayConfig['closeTime']);
    if (openTime == null || closeTime == null) {
      return null;
    }

    final openMinutes = _timeToMinutes(openTime);
    if (openMinutes < 0) {
      return null;
    }

    final closeMinutes = closeTime == '24:00'
        ? 24 * 60
        : _timeToMinutes(closeTime);
    if (closeMinutes <= openMinutes) {
      return null;
    }

    return (openMinutes: openMinutes, closeMinutes: closeMinutes);
  }

  static String? _normalizeTimeString(Object? value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }

    final parts = raw.split(':');
    if (parts.length < 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    if (hour < 0 || hour > 24 || minute < 0 || minute > 59) {
      return null;
    }

    if (hour == 24 && minute == 0) {
      return '24:00';
    }

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  static List<String> _enumerateSlotTimes({
    required int openMinutes,
    required int closeMinutes,
    required int slotMinutes,
  }) {
    final times = <String>[];
    for (
      var minutes = openMinutes;
      minutes < closeMinutes;
      minutes += slotMinutes
    ) {
      final hour = minutes ~/ 60;
      final minute = minutes % 60;
      times.add(
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
      );
    }
    return times;
  }

  static Map<String, int> _reservedGuestCountByTime({
    required List<Reservation> reservations,
    required DateTime targetDate,
  }) {
    final dateKey =
        '${targetDate.year.toString().padLeft(4, '0')}-'
        '${targetDate.month.toString().padLeft(2, '0')}-'
        '${targetDate.day.toString().padLeft(2, '0')}';

    final map = <String, int>{};
    for (final reservation in reservations) {
      final bookingDateKey =
          '${reservation.bookingDate.year.toString().padLeft(4, '0')}-'
          '${reservation.bookingDate.month.toString().padLeft(2, '0')}-'
          '${reservation.bookingDate.day.toString().padLeft(2, '0')}';
      if (bookingDateKey != dateKey) {
        continue;
      }
      if (reservation.status.dbValue != 'confirmed') {
        continue;
      }
      final time = reservation.bookingTime;
      map[time] = (map[time] ?? 0) + reservation.guestCount;
    }
    return map;
  }

  static int _seoulNowMinutes(DateTime now) {
    const seoulOffset = Duration(hours: 9);
    final shiftedMs =
        now.toUtc().millisecondsSinceEpoch + seoulOffset.inMilliseconds;
    final labeled = DateTime.fromMillisecondsSinceEpoch(shiftedMs, isUtc: true);
    return labeled.hour * 60 + labeled.minute;
  }

  static int _timeToMinutes(String time) {
    final normalized = _normalizeTimeString(time);
    if (normalized == null) {
      return -1;
    }
    if (normalized == '24:00') {
      return 24 * 60;
    }

    final parts = normalized.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
