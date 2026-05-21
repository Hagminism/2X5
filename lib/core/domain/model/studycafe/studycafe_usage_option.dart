import 'package:freezed_annotation/freezed_annotation.dart';

part 'studycafe_usage_option.freezed.dart';
part 'studycafe_usage_option.g.dart';

@freezed
abstract class StudyCafeUsageOption with _$StudyCafeUsageOption {
  const factory StudyCafeUsageOption({
    @JsonKey(name: 'duration_minutes') required int durationMinutes,
    required int price,
    @JsonKey(name: 'is_enabled') @Default(true) bool isEnabled,
  }) = _StudyCafeUsageOption;

  factory StudyCafeUsageOption.fromJson(Map<String, Object?> json) =>
      _$StudyCafeUsageOptionFromJson(json);
}
