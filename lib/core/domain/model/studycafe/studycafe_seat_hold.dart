import 'package:freezed_annotation/freezed_annotation.dart';

part 'studycafe_seat_hold.freezed.dart';
part 'studycafe_seat_hold.g.dart';

@freezed
abstract class StudyCafeSeatHold with _$StudyCafeSeatHold {
  const StudyCafeSeatHold._();

  const factory StudyCafeSeatHold({
    required String id,
    @JsonKey(name: 'store_id') required String storeId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'seat_id') required String seatId,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    @Default('active') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _StudyCafeSeatHold;

  bool get isActive {
    return status == 'active' && expiresAt.isAfter(DateTime.now());
  }

  factory StudyCafeSeatHold.fromJson(Map<String, Object?> json) =>
      _$StudyCafeSeatHoldFromJson(json);
}
