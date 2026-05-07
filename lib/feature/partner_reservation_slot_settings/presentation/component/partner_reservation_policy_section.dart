import 'package:capstone_2026/feature/partner_reservation_slot_settings/domain/enum/reservation_slot_interval.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerReservationPolicySection extends StatelessWidget {
  final ReservationSlotInterval selectedInterval;
  final void Function(ReservationSlotInterval interval) onSelectInterval;

  const PartnerReservationPolicySection({
    super.key,
    required this.selectedInterval,
    required this.onSelectInterval,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF8F8F8),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '예약 운영 정책',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: ReservationSlotInterval.values.map((interval) {
              final isSelected = selectedInterval == interval;
              return ChoiceChip(
                label: Text(interval.label),
                selected: isSelected,
                onSelected: (isOn) {
                  if (!isOn) {
                    return;
                  }
                  onSelectInterval(interval);
                },
                selectedColor: const Color(0x1AFF5A00),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Text(
            '혼잡도 기준: 0~25% 여유 · 26~50% 보통 · 51~75% 혼잡 · 76~99% 포화 · 100% 마감',
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
