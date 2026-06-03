import 'package:freezed_annotation/freezed_annotation.dart';

part 'coupon_box_action.freezed.dart';

@freezed
sealed class CouponBoxAction with _$CouponBoxAction {
  const factory CouponBoxAction.changeTab(int index) = ChangeTab;
  const factory CouponBoxAction.selectCategory(String category) =
      SelectCategory;
  const factory CouponBoxAction.tapUseCoupon(String couponId) = TapUseCoupon;
  const factory CouponBoxAction.confirmUseCoupon(String couponId) =
      ConfirmUseCoupon;
}
