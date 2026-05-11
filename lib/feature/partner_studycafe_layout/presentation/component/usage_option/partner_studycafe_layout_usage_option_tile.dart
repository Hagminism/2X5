import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/screen/partner_studycafe_layout_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerStudyCafeLayoutUsageOptionTile extends StatelessWidget {
  final int index;
  final int durationMinutes;
  final int price;
  final bool isEnabled;
  final void Function(PartnerStudyCafeLayoutAction action) onAction;

  const PartnerStudyCafeLayoutUsageOptionTile({
    super.key,
    required this.index,
    required this.durationMinutes,
    required this.price,
    required this.isEnabled,
    required this.onAction,
  });

  static InputDecoration _numericFieldDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: AppColors.surfaceMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('duration-$index-$durationMinutes'),
                    initialValue: durationMinutes.toString(),
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                    decoration: _numericFieldDecoration('이용 시간(분)'),
                    onChanged: (String value) => onAction(
                      PartnerStudyCafeLayoutAction.changeUsageOptionDuration(
                        index: index,
                        value: value,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('price-$index-$price'),
                    initialValue: price.toString(),
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                    decoration: _numericFieldDecoration('가격(원)'),
                    onChanged: (String value) => onAction(
                      PartnerStudyCafeLayoutAction.changeUsageOptionPrice(
                        index: index,
                        value: value,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '활성화',
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(width: 10),
                Switch(
                  value: isEnabled,
                  activeThumbColor: AppColors.primary,
                  trackOutlineColor: WidgetStateProperty.all(AppColors.border),
                  onChanged: (bool value) => onAction(
                    PartnerStudyCafeLayoutAction.toggleUsageOptionEnabled(
                      index: index,
                      value: value,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onAction(
                    PartnerStudyCafeLayoutAction.removeUsageOption(index),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}