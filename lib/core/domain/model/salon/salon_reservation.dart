import 'package:freezed_annotation/freezed_annotation.dart';

part 'salon_reservation.freezed.dart';
part 'salon_reservation.g.dart';

@freezed
abstract class SalonReservation with _$SalonReservation {
  const SalonReservation._();

  const factory SalonReservation({
    required String id,
    @JsonKey(name: 'store_id') required String storeId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'designer_id') required String designerId,
    @JsonKey(name: 'service_ids') @Default([]) List<String> serviceIds,
    @JsonKey(name: 'start_at') required DateTime startAt,
    @JsonKey(name: 'end_at') required DateTime endAt,
    @JsonKey(name: 'slot_minutes') @Default(30) int slotMinutes,
    @Default('confirmed') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SalonReservation;

  bool get isConfirmed => status == 'confirmed';

  factory SalonReservation.fromJson(Map<String, Object?> json) =>
      _$SalonReservationFromJson(json);
}
