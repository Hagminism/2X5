import 'package:collection/collection.dart';

enum ReservationStatus {
  pending,
  confirmed,
  cancelled,
  noShow,
  completed
  ;

  String get dbValue => switch (this) {
    ReservationStatus.pending => 'pending',
    ReservationStatus.confirmed => 'confirmed',
    ReservationStatus.cancelled => 'cancelled',
    ReservationStatus.noShow => 'noShow',
    ReservationStatus.completed => 'completed',
  };

  String get label => switch (this) {
    ReservationStatus.pending => '대기',
    ReservationStatus.confirmed => '확정',
    ReservationStatus.cancelled => '취소',
    ReservationStatus.noShow => '노쇼',
    ReservationStatus.completed => '방문완료',
  };

  static ReservationStatus? fromDbValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return values.firstWhereOrNull((status) => status.dbValue == value);
  }
}
