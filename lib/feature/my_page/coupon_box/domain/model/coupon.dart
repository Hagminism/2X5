import 'package:freezed_annotation/freezed_annotation.dart';

part 'coupon.freezed.dart';
part 'coupon.g.dart';

@freezed
abstract class Coupon with _$Coupon {
  const factory Coupon({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'store_id') required String storeId,
    @JsonKey(name: 'store_name') required String storeName,
    @JsonKey(name: 'store_category') required String storeCategory,
    @JsonKey(name: 'reward_title') required String rewardTitle,
    @JsonKey(name: 'reward_description') String? rewardDescription,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'expired_at') required DateTime expiredAt,
    @JsonKey(name: 'used_at') DateTime? usedAt,
  }) = _Coupon;

  factory Coupon.fromJson(Map<String, dynamic> json) => _$CouponFromJson(json);
}
