import 'package:freezed_annotation/freezed_annotation.dart';

part 'salon_designer_schedule.freezed.dart';
part 'salon_designer_schedule.g.dart';

@freezed
abstract class SalonDesignerSchedule with _$SalonDesignerSchedule {
  const factory SalonDesignerSchedule({
    required String id,
    @JsonKey(name: 'designer_id') required String designerId,
    @JsonKey(name: 'day_of_week') required int dayOfWeek,
    @JsonKey(name: 'is_working') @Default(true) bool isWorking,
    @JsonKey(name: 'start_time') @Default('10:00') String startTime,
    @JsonKey(name: 'end_time') @Default('19:00') String endTime,
    @JsonKey(name: 'slot_minutes') @Default(30) int slotMinutes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SalonDesignerSchedule;

  factory SalonDesignerSchedule.fromJson(Map<String, Object?> json) =>
      _$SalonDesignerScheduleFromJson(json);
}
