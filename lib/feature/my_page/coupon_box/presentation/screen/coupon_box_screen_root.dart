import 'dart:async';

import 'package:capstone_2026/feature/my_page/coupon_box/presentation/screen/coupon_box_action.dart';
import 'package:capstone_2026/feature/my_page/coupon_box/presentation/screen/coupon_box_event.dart';
import 'package:capstone_2026/feature/my_page/coupon_box/presentation/screen/coupon_box_screen.dart';
import 'package:capstone_2026/feature/my_page/coupon_box/presentation/screen/coupon_box_view_model.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
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
        case ShowMessage():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(event.message),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(milliseconds: 1400),
            ),
          );
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
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.white,
          title: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                '쿠폰 사용 확인',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '[$storeName]',
                style: AppTextStyles.bodySecondary.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rewardTitle,
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '매장 관계자에게 이 화면을 보여주세요.\n관계자가 아래의 \'사용 확인\'을 누르면 쿠폰이 즉시 사용 완료 처리됩니다.',
                style: AppTextStyles.bodySecondary.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.only(
            bottom: 16,
            right: 16,
            left: 16,
          ),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      '사용 확인',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.viewModel.onAction(
                        CouponBoxAction.confirmUseCoupon(couponId),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
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
