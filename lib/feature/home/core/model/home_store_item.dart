import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_store_item.freezed.dart';
part 'home_store_item.g.dart';

@freezed
abstract class HomeStoreItem with _$HomeStoreItem {
  const factory HomeStoreItem({
    required String storeId,
    required String name,
    required String subtitle,
    required double rating,
    required String category,
    String? imageUrl,
    @Default(false) bool isBookmarked,
  }) = _HomeStoreItem;

  factory HomeStoreItem.fromJson(Map<String, Object?> json) =>
      _$HomeStoreItemFromJson(json);
}