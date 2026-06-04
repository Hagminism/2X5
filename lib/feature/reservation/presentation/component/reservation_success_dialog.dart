import 'package:capstone_2026/feature/reservation/presentation/component/reservation_dialog_summary.dart';
import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class ReservationSuccessDialog extends StatelessWidget {
  final DateTime bookingDate;
  final String bookingTime;
  final int guestCount;
  final String? customerRequest;
  final VoidCallback onConfirm;

  const ReservationSuccessDialog({
    super.key,
    required this.bookingDate,
    required this.bookingTime,
    required this.guestCount,
    this.customerRequest,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '예약이 완료되었습니다',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 8),
            const Text(
              '아래 내용으로 예약이 확정되었어요.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 20),
            ReservationDialogSummary(
              bookingDate: bookingDate,
              bookingTime: bookingTime,
              guestCount: guestCount,
              customerRequest: customerRequest,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: '확인',
              onTap: onConfirm,
            ),
          ],
        ),
      ),
    );
  }
}
