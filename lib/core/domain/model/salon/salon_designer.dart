import 'package:freezed_annotation/freezed_annotation.dart';

part 'salon_designer.freezed.dart';
part 'salon_designer.g.dart';

@freezed
abstract class SalonDesigner with _$SalonDesigner {
  const factory SalonDesigner({
    required String id,
    @JsonKey(name: 'store_id') required String storeId,
    required String name,
    @Default('') String introduction,
    @JsonKey(name: 'image_url') @Default('') String imageUrl,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SalonDesigner;

  factory SalonDesigner.fromJson(Map<String, Object?> json) =>
      _$SalonDesignerFromJson(json);
}
