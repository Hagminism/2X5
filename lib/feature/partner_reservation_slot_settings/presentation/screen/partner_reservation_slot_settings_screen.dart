import 'package:capstone_2026/feature/partner_reservation_slot_settings/domain/enum/reservation_congestion_level.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/domain/enum/reservation_slot_interval.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/domain/model/partner_reservation_slot.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/screen/partner_reservation_slot_settings_action.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/screen/partner_reservation_slot_settings_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerReservationSlotSettingsScreen extends StatelessWidget {
  final PartnerReservationSlotSettingsState state;
  final void Function(PartnerReservationSlotSettingsAction action) onAction;

  const PartnerReservationSlotSettingsScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        elevation: 0,
        title: const Text(
          '시간대 운영 설정',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReservationPolicySection(),
            _buildSlotOperationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationPolicySection() {
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
              final isSelected = state.slotInterval == interval;
              return ChoiceChip(
                label: Text(interval.label),
                selected: isSelected,
                onSelected: (isOn) {
                  if (!isOn) {
                    return;
                  }
                  onAction(ChangeSlotInterval(interval));
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

  Widget _buildSlotOperationSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '시간대 운영',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  onAction(const TapDatePicker());
                },
                icon: const Icon(Icons.calendar_month, size: 16),
                label: Text(_formatDate(state.selectedDate)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...state.slots.map(_buildSlotCard),
        ],
      ),
    );
  }

  Widget _buildSlotCard(PartnerReservationSlot slot) {
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
                onChanged: (isOpen) {
                  onAction(ToggleSlotOpen(time: slot.time, isOpen: isOpen));
                },
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
              _countButton(
                icon: Icons.remove,
                onTap: () {
                  onAction(TapDecreaseMaxTeamCount(slot.time));
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${slot.maxTeamCount}팀',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              _countButton(
                icon: Icons.add,
                onTap: () {
                  onAction(TapIncreaseMaxTeamCount(slot.time));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _countButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE4E4E4)),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
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
