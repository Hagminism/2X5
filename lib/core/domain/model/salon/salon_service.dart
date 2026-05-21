import 'package:freezed_annotation/freezed_annotation.dart';

part 'salon_service.freezed.dart';
part 'salon_service.g.dart';

@freezed
abstract class SalonService with _$SalonService {
  const factory SalonService({
    required String id,
    @JsonKey(name: 'store_id') required String storeId,
    required String name,
    @Default('') String description,
    @JsonKey(name: 'duration_minutes') required int durationMinutes,
    required int price,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SalonService;

  factory SalonService.fromJson(Map<String, Object?> json) =>
      _$SalonServiceFromJson(json);
}
