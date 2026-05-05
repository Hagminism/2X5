import 'package:capstone_2026/core/domain/model/enum/reservation_status.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerReservationStatusBadge extends StatelessWidget {
  final ReservationStatus status;

  const PartnerReservationStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, textColor) = switch (status) {
      ReservationStatus.pending => (
        const Color(0xFFFFF4E5),
        const Color(0xFFB45309),
      ),
      ReservationStatus.confirmed => (
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32),
      ),
      ReservationStatus.cancelled => (
        const Color(0xFFFFEBEE),
        const Color(0xFFC62828),
      ),
      ReservationStatus.noShow => (
        const Color(0xFFF3E8FF),
        const Color(0xFF6B21A8),
      ),
      ReservationStatus.completed => (
        const Color(0xFFE3F2FD),
        const Color(0xFF1565C0),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.label.copyWith(
          color: textColor,
          fontSize: 11,
        ),
      ),
    );
  }
}
