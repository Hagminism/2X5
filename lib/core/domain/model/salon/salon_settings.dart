import 'package:freezed_annotation/freezed_annotation.dart';

part 'salon_settings.freezed.dart';
part 'salon_settings.g.dart';

@freezed
abstract class SalonSettings with _$SalonSettings {
  const factory SalonSettings({
    @JsonKey(name: 'store_id') required String storeId,
    @JsonKey(name: 'slot_minutes') @Default(30) int slotMinutes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SalonSettings;

  factory SalonSettings.defaultForStore(String storeId) {
    return SalonSettings(storeId: storeId);
  }

  factory SalonSettings.fromJson(Map<String, Object?> json) =>
      _$SalonSettingsFromJson(json);
}
