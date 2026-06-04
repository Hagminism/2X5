import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/component/salon_reservation_dialog_summary.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class SalonReservationConfirmDialog extends StatelessWidget {
  final String designerName;
  final String selectedDateTime;
  final String serviceNames;
  final String? customerRequest;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const SalonReservationConfirmDialog({
    super.key,
    required this.designerName,
    required this.selectedDateTime,
    required this.serviceNames,
    this.customerRequest,
    required this.onCancel,
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
                Icons.event_available_outlined,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '예약 내용을 확인해 주세요',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 8),
            const Text(
              '아래 내용으로 예약을 진행할까요?',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 20),
            SalonReservationDialogSummary(
              designerName: designerName,
              selectedDateTime: selectedDateTime,
              serviceNames: serviceNames,
              customerRequest: customerRequest,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: '예약 확정',
                    height: 52,
                    onTap: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
