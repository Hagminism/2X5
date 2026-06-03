import 'package:capstone_2026/feature/my_page/coupon_box/domain/model/coupon.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'coupon_box_state.freezed.dart';

@freezed
abstract class CouponBoxState with _$CouponBoxState {
  const CouponBoxState._();

  const factory CouponBoxState({
    @Default(false) bool isLoading,
    @Default(0) int tabIndex,
    @Default('all') String selectedCategory,
    @Default(<Coupon>[]) List<Coupon> coupons,
  }) = _CouponBoxState;

  List<Coupon> get filteredCoupons => filteredCouponsForTab(tabIndex);

  List<Coupon> filteredCouponsForTab(int targetTabIndex) {
    final now = DateTime.now();
    return coupons.where((coupon) {
      // 1. 탭 필터링 (0: 사용 가능, 1: 사용 완료/만료)
      final isUsed = coupon.usedAt != null;
      final isExpired = coupon.expiredAt.isBefore(now);

      if (targetTabIndex == 0) {
        if (isUsed || isExpired) return false;
      } else {
        if (!isUsed && !isExpired) return false;
      }

      // 2. 카테고리 필터링
      if (selectedCategory != 'all' &&
          coupon.storeCategory != selectedCategory) {
        return false;
      }

      return true;
    }).toList();
  }
}
