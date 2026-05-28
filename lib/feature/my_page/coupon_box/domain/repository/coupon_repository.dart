import 'package:capstone_2026/feature/my_page/coupon_box/domain/model/coupon.dart';

abstract interface class CouponRepository {
  Future<List<Coupon>> fetchUserCoupons({required String userId});
  Future<void> useCoupon({required String couponId});
}
