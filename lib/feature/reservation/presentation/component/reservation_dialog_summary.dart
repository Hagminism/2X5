import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatReservationDateLabel(DateTime date) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  final weekday = weekdays[date.weekday - 1];
  return '${DateFormat('M월 d일').format(date)} ($weekday)';
}

class ReservationDialogSummary extends StatelessWidget {
  final DateTime bookingDate;
  final String bookingTime;
  final int guestCount;
  final String? customerRequest;

  const ReservationDialogSummary({
    super.key,
    required this.bookingDate,
    required this.bookingTime,
    required this.guestCount,
    this.customerRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.signUpWithEmailButton,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.calendar_today_outlined,
            label: '날짜',
            value: formatReservationDateLabel(bookingDate),
          ),
          const Divider(height: 1, color: AppColors.border),
          _SummaryRow(
            icon: Icons.schedule_outlined,
            label: '시간',
            value: bookingTime,
          ),
          const Divider(height: 1, color: AppColors.border),
          _SummaryRow(
            icon: Icons.people_outline,
            label: '인원',
            value: '$guestCount명',
          ),
          if (customerRequest != null && customerRequest!.trim().isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.border),
            _SummaryRow(
              icon: Icons.notes_outlined,
              label: '요구사항',
              value: customerRequest!,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
