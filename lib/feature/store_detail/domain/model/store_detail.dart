import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_detail.freezed.dart';
part 'store_detail.g.dart';

@freezed
abstract class StoreDetail with _$StoreDetail {
  const factory StoreDetail({
    required String name,
    required String category,
    required double rating,
    required int reviewCount,
    required String description,
    required String location,
    required String priceRange,
    required String openHours,
    required List<String> tags,
    required String naverPlaceId,
    required String googleSearchQuery,
  }) = _StoreDetail;

  factory StoreDetail.fromJson(Map<String, Object?> json) =>
      _$StoreDetailFromJson(json);
}

const emptyStoreDetail = StoreDetail(
  name: '',
  category: '',
  rating: 0,
  reviewCount: 0,
  description: '',
  location: '',
  priceRange: '',
  openHours: '',
  tags: [],
  naverPlaceId: '',
  googleSearchQuery: '',
);
