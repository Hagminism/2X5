import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_image.freezed.dart';
part 'store_image.g.dart';

@freezed
abstract class StoreImage with _$StoreImage {
  const factory StoreImage({
    String? id,
    required String imageUrl,
    @Default('') String caption,
    required int sortOrder,
    @Default(false) bool isCover,
  }) = _StoreImage;

  factory StoreImage.fromJson(Map<String, Object?> json) =>
      _$StoreImageFromJson(json);
}
