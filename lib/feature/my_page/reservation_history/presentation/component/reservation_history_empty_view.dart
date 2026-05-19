import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class ReservationHistoryEmptyView extends StatelessWidget {
  const ReservationHistoryEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              '아직 이용 내역이 없습니다.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '예약을 완료하면 이곳에서 이용 내역을 확인할 수 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
