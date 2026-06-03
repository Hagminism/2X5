import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

part 'coupon_box_event.freezed.dart';

@freezed
sealed class CouponBoxEvent with _$CouponBoxEvent {
  const factory CouponBoxEvent.showMessage(
    String message, {
    @Default(AppSnackBarVariant.error) AppSnackBarVariant variant,
  }) = ShowMessage;
  const factory CouponBoxEvent.showUseConfirmationDialog({
    required String couponId,
    required String storeName,
    required String rewardTitle,
  }) = ShowUseConfirmationDialog;
}
