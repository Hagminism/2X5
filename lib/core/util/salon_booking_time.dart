/// 미용실 예약 RPC(`create_salon_reservation`)와 동일하게 **Asia/Seoul** 벽시계(고정 UTC+9)를 사용한다.
abstract final class SalonBookingTime {
  static const Duration _seoulOffset = Duration(hours: 9);

  /// 서울 달력 [year]/[month]/[day]의 [hour]:[minute] 벽시각에 해당하는 UTC [DateTime].
  static DateTime seoulWallToUtc(
    int year,
    int month,
    int day,
    int hour,
    int minute,
  ) {
    return DateTime.utc(year, month, day, hour, minute).subtract(_seoulOffset);
  }

  /// 서울 달력 하루의 시작(0시)에 해당하는 UTC 순간.
  static DateTime seoulDayStartUtc(int year, int month, int day) {
    return seoulWallToUtc(year, month, day, 0, 0);
  }

  /// 서울 달력 [year]/[month]/[day]의 다음날 0시(배타 구간 끝) UTC 순간.
  static DateTime seoulDayEndExclusiveUtc(int year, int month, int day) {
    return seoulDayStartUtc(year, month, day).add(const Duration(days: 1));
  }

  /// PostgreSQL `extract(dow from ... at time zone 'Asia/Seoul')` 와 동일: 일요일 = 0 … 토요일 = 6
  static int seoulPostgresDayOfWeek(int year, int month, int day) {
    final shiftedMs =
        seoulWallToUtc(year, month, day, 12, 0).millisecondsSinceEpoch +
        _seoulOffset.inMilliseconds;
    final labeled = DateTime.fromMillisecondsSinceEpoch(shiftedMs, isUtc: true);
    return labeled.weekday % 7;
  }

  /// 현재 시각 기준 서울 달력의 연·월·일.
  static ({int year, int month, int day}) seoulTodayCalendar() {
    final nowUtc = DateTime.now().toUtc();
    final shiftedMs = nowUtc.millisecondsSinceEpoch + _seoulOffset.inMilliseconds;
    final labeled = DateTime.fromMillisecondsSinceEpoch(shiftedMs, isUtc: true);
    return (year: labeled.year, month: labeled.month, day: labeled.day);
  }

  /// [utcInstant]에 해당하는 서울 벽시계 시:분(`HH:mm`).
  static String seoulClockHHmm(DateTime utcInstant) {
    final shiftedMs =
        utcInstant.toUtc().millisecondsSinceEpoch + _seoulOffset.inMilliseconds;
    final labeled = DateTime.fromMillisecondsSinceEpoch(shiftedMs, isUtc: true);
    final h = labeled.hour.toString().padLeft(2, '0');
    final m = labeled.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// [isoDate] UTC 기준 파싱 후 서울 벽시계로 `YYYY년 M월 D일 HH:mm` 형식.
  static String seoulKoreanDateTimeLabel(String isoDate) {
    if (isoDate.isEmpty) {
      return '';
    }
    try {
      final utc = DateTime.parse(isoDate).toUtc();
      final shiftedMs =
          utc.millisecondsSinceEpoch + _seoulOffset.inMilliseconds;
      final labeled =
          DateTime.fromMillisecondsSinceEpoch(shiftedMs, isUtc: true);
      final h = labeled.hour.toString().padLeft(2, '0');
      final m = labeled.minute.toString().padLeft(2, '0');
      return '${labeled.year}년 ${labeled.month}월 ${labeled.day}일 $h:$m';
    } catch (_) {
      return isoDate;
    }
  }
}
