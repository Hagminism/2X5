import 'package:freezed_annotation/freezed_annotation.dart';

part 'studycafe_reservation.freezed.dart';
part 'studycafe_reservation.g.dart';

@freezed
abstract class StudyCafeReservation with _$StudyCafeReservation {
  const StudyCafeReservation._();

  const factory StudyCafeReservation({
    required String id,
    @JsonKey(name: 'store_id') required String storeId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'seat_id') required String seatId,
    @JsonKey(name: 'duration_minutes') required int durationMinutes,
    @JsonKey(name: 'start_at') required DateTime startAt,
    @JsonKey(name: 'end_at') required DateTime endAt,
    @Default('confirmed') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _StudyCafeReservation;

  bool get isActive {
    return status == 'confirmed' && endAt.isAfter(DateTime.now());
  }

  factory StudyCafeReservation.fromJson(Map<String, Object?> json) =>
      _$StudyCafeReservationFromJson(json);
}
