import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerReservationEmptyView extends StatelessWidget {
  final void Function() onRetry;

  const PartnerReservationEmptyView({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_busy_outlined,
              color: AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              '표시할 예약이 없습니다.',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '상태/날짜 필터를 변경하거나 잠시 후 다시 시도해 주세요.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: const Text('새로고침'),
            ),
          ],
        ),
      ),
    );
  }
}
