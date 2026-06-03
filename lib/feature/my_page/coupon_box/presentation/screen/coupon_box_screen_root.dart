import 'dart:async';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';
import 'package:capstone_2026/feature/my_page/coupon_box/presentation/component/coupon_use_confirm_dialog.dart';
import 'package:capstone_2026/feature/my_page/coupon_box/presentation/screen/coupon_box_action.dart';
import 'package:capstone_2026/feature/my_page/coupon_box/presentation/screen/coupon_box_event.dart';
import 'package:capstone_2026/feature/my_page/coupon_box/presentation/screen/coupon_box_screen.dart';
import 'package:capstone_2026/feature/my_page/coupon_box/presentation/screen/coupon_box_view_model.dart';
import 'package:flutter/material.dart';

class CouponBoxScreenRoot extends StatefulWidget {
  const CouponBoxScreenRoot({
    super.key,
    required this.viewModel,
  });

  final CouponBoxViewModel viewModel;

  @override
  State<CouponBoxScreenRoot> createState() => _CouponBoxScreenRootState();
}

class _CouponBoxScreenRootState extends State<CouponBoxScreenRoot> {
  StreamSubscription<CouponBoxEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    widget.viewModel.loadCoupons();

    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (!mounted) return;

      switch (event) {
        case ShowMessage(:final message, :final variant):
          AppSnackBar.show(context, message, variant: variant);
          break;
        case ShowUseConfirmationDialog():
          _showUseConfirmationDialog(
            couponId: event.couponId,
            storeName: event.storeName,
            rewardTitle: event.rewardTitle,
          );
          break;
      }
    });
  }

  void _showUseConfirmationDialog({
    required String couponId,
    required String storeName,
    required String rewardTitle,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return CouponUseConfirmDialog(
          storeName: storeName,
          rewardTitle: rewardTitle,
          onConfirm: () {
            widget.viewModel.onAction(
              CouponBoxAction.confirmUseCoupon(couponId),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return CouponBoxScreen(
          state: widget.viewModel.state,
          onAction: widget.viewModel.onAction,
        );
      },
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
