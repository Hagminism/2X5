import 'package:freezed_annotation/freezed_annotation.dart';

part 'coupon_box_event.freezed.dart';

@freezed
sealed class CouponBoxEvent with _$CouponBoxEvent {
  const factory CouponBoxEvent.showMessage(String message) = ShowMessage;
  const factory CouponBoxEvent.showUseConfirmationDialog({
    required String couponId,
    required String storeName,
    required String rewardTitle,
  }) = ShowUseConfirmationDialog;
}
