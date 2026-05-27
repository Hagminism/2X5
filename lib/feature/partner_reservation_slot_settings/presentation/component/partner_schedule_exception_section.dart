import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/screen/partner_reservation_slot_settings_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerScheduleExceptionSection extends StatelessWidget {
  final bool isClosed;
  final String? openTime;
  final String? closeTime;
  final void Function(PartnerReservationSlotSettingsAction action) onAction;

  const PartnerScheduleExceptionSection({
    super.key,
    required this.isClosed,
    required this.openTime,
    required this.closeTime,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '선택일 예외 설정',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('해당일 전체 휴무'),
            value: isClosed,
            activeThumbColor: AppColors.primary,
            onChanged: (value) {
              onAction(ToggleExceptionClosed(value));
            },
          ),
          if (!isClosed) ...[
            _TimeField(
              label: '임시 오픈',
              value: openTime,
              onChanged: (value) {
                onAction(ChangeExceptionOpenTime(value));
              },
            ),
            const SizedBox(height: 8),
            _TimeField(
              label: '임시 마감',
              value: closeTime,
              onChanged: (value) {
                onAction(ChangeExceptionCloseTime(value));
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final String? value;
  final void Function(String? value) onChanged;

  const _TimeField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'HH:mm',
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
