import 'package:capstone_2026/core/domain/model/enum/reservation_status.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class ReservationHistoryStatusBadge extends StatelessWidget {
  final ReservationStatus status;

  const ReservationHistoryStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, foregroundColor) = switch (status) {
      ReservationStatus.confirmed => (
        const Color(0xFFE8F7EE),
        const Color(0xFF15803D),
      ),
      ReservationStatus.completed => (
        const Color(0xFFEFF6FF),
        const Color(0xFF1D4ED8),
      ),
      ReservationStatus.cancelled => (
        const Color(0xFFF3F4F6),
        AppColors.textSecondary,
      ),
      ReservationStatus.noShow => (
        const Color(0xFFFEE2E2),
        AppColors.danger,
      ),
      ReservationStatus.pending => (
        const Color(0xFFFFF7ED),
        AppColors.primary,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: foregroundColor,
        ),
      ),
    );
  }
}
