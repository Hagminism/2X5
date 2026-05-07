import 'package:capstone_2026/feature/partner_reservation_slot_settings/domain/enum/reservation_congestion_level.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/domain/model/partner_reservation_slot.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/component/partner_reservation_slot_count_button.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerReservationSlotCard extends StatelessWidget {
  final PartnerReservationSlot slot;
  final void Function(bool isOpen) onToggleOpen;
  final VoidCallback onTapDecreaseTeamCount;
  final VoidCallback onTapIncreaseTeamCount;

  const PartnerReservationSlotCard({
    super.key,
    required this.slot,
    required this.onToggleOpen,
    required this.onTapDecreaseTeamCount,
    required this.onTapIncreaseTeamCount,
  });

  @override
  Widget build(BuildContext context) {
    final congestionColor = _congestionColor(slot.congestionLevel);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: slot.isOpen ? Colors.white : const Color(0xFFF5F5F5),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                slot.time,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: congestionColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  slot.congestionLevel.label,
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 11,
                    color: congestionColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Switch(
                value: slot.isOpen,
                activeThumbColor: AppColors.primary,
                onChanged: onToggleOpen,
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '예약 ${slot.reservedTeamCount}팀 / 최대 ${slot.maxTeamCount}팀 (잔여 ${slot.remainingTeamCount}팀)',
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
              ),
              const Spacer(),
              PartnerReservationSlotCountButton(
                icon: Icons.remove,
                onTap: onTapDecreaseTeamCount,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${slot.maxTeamCount}팀',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PartnerReservationSlotCountButton(
                icon: Icons.add,
                onTap: onTapIncreaseTeamCount,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _congestionColor(ReservationCongestionLevel level) {
    switch (level) {
      case ReservationCongestionLevel.relaxed:
        return Colors.green;
      case ReservationCongestionLevel.normal:
        return Colors.blue;
      case ReservationCongestionLevel.busy:
        return Colors.orange;
      case ReservationCongestionLevel.saturated:
        return Colors.deepOrange;
      case ReservationCongestionLevel.closed:
        return Colors.red;
    }
  }
}
