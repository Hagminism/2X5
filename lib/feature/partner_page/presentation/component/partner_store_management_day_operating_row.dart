import 'package:capstone_2026/core/presentation/util/app_time_picker.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerStoreManagementDayOperatingRow extends StatelessWidget {
  final String dayLabel;
  final bool isOpened;
  final String openTime;
  final String closeTime;
  final void Function(bool value) onToggleOpened;
  final void Function(String value) onSelectOpenTime;
  final void Function(String value) onSelectCloseTime;

  const PartnerStoreManagementDayOperatingRow({
    super.key,
    required this.dayLabel,
    required this.isOpened,
    required this.openTime,
    required this.closeTime,
    required this.onToggleOpened,
    required this.onSelectOpenTime,
    required this.onSelectCloseTime,
  });

  @override
  Widget build(BuildContext context) {
    final hasEqualTimeError =
        isOpened &&
        openTime.isNotEmpty &&
        closeTime.isNotEmpty &&
        openTime == closeTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                dayLabel,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: isOpened,
              activeThumbColor: AppColors.primary,
              onChanged: onToggleOpened,
            ),
            const SizedBox(width: 4),
            Text(
              isOpened ? '영업' : '휴무',
              style: AppTextStyles.bodySecondary.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _TimeSelectButton(
                context: context,
                isStartTime: true,
                value: openTime,
                enabled: isOpened,
                onSelected: onSelectOpenTime,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '~',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TimeSelectButton(
                context: context,
                isStartTime: false,
                value: closeTime,
                enabled: isOpened,
                onSelected: onSelectCloseTime,
              ),
            ),
          ],
        ),
        if (hasEqualTimeError) ...[
          const SizedBox(height: 6),
          Text(
            '시작 시간과 종료 시간은 같을 수 없습니다.',
            style: AppTextStyles.bodySecondary.copyWith(
              color: AppColors.danger,
            ),
          ),
        ],
      ],
    );
  }
}

class _TimeSelectButton extends StatelessWidget {
  final BuildContext context;
  final bool isStartTime;
  final String value;
  final bool enabled;
  final ValueChanged<String> onSelected;

  const _TimeSelectButton({
    required this.context,
    required this.isStartTime,
    required this.value,
    required this.enabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final label = isStartTime ? '시작 시간' : '종료 시간';
    final borderRadius = BorderRadius.circular(12);

    return SizedBox(
      height: 48,
      child: Material(
        color: enabled ? AppColors.signInTextField : AppColors.border,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: !enabled
              ? null
              : () async {
                  final selected = await AppTimePicker.show(
                    this.context,
                    initialTime: _toInitialTime(value),
                  );
                  if (selected == null) return;
                  onSelected(_formatTime(selected));
                },
          child: Center(
            child: Text(
              value.isEmpty ? label : value,
              style: AppTextStyles.body.copyWith(
                color: value.isEmpty
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  TimeOfDay _toInitialTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) {
      return TimeOfDay.now();
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return TimeOfDay.now();
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
