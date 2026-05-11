import 'package:freezed_annotation/freezed_annotation.dart';

part 'studycafe_seat.freezed.dart';
part 'studycafe_seat.g.dart';

@freezed
abstract class StudyCafeSeat with _$StudyCafeSeat {
  const factory StudyCafeSeat({
    @JsonKey(name: 'seat_id') required String seatId,
    required String label,
    required double x,
    required double y,
    @JsonKey(name: 'is_enabled') @Default(true) bool isEnabled,
    @Default('open') String type,
  }) = _StudyCafeSeat;

  factory StudyCafeSeat.fromJson(Map<String, Object?> json) =>
      _$StudyCafeSeatFromJson(json);
}
