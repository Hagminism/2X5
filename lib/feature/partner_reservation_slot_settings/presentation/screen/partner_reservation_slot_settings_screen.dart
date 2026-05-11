import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/component/partner_reservation_policy_section.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/component/partner_reservation_slot_card.dart';
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
            PartnerReservationPolicySection(
              selectedInterval: state.slotInterval,
              onSelectInterval: (interval) {
                onAction(ChangeSlotInterval(interval));
              },
            ),
            Container(
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
                  ...state.slots.map(
                    (slot) => PartnerReservationSlotCard(
                      slot: slot,
                      onToggleOpen: (isOpen) {
                        onAction(
                          ToggleSlotOpen(time: slot.time, isOpen: isOpen),
                        );
                      },
                      onTapDecreaseTeamCount: () {
                        onAction(TapDecreaseMaxTeamCount(slot.time));
                      },
                      onTapIncreaseTeamCount: () {
                        onAction(TapIncreaseMaxTeamCount(slot.time));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }
}
