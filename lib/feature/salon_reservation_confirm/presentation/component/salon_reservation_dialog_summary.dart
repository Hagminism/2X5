import 'package:capstone_2026/core/util/salon_booking_time.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class SalonReservationDialogSummary extends StatelessWidget {
  final String designerName;
  final String selectedDateTime;
  final String serviceNames;
  final String? customerRequest;

  const SalonReservationDialogSummary({
    super.key,
    required this.designerName,
    required this.selectedDateTime,
    required this.serviceNames,
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
            icon: Icons.person_outline,
            label: '디자이너',
            value: designerName,
          ),
          const Divider(height: 1, color: AppColors.border),
          _SummaryRow(
            icon: Icons.schedule_outlined,
            label: '일정',
            value: SalonBookingTime.seoulKoreanDateTimeLabel(selectedDateTime),
          ),
          const Divider(height: 1, color: AppColors.border),
          _SummaryRow(
            icon: Icons.content_cut_outlined,
            label: '시술',
            value: serviceNames,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
