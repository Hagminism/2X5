import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/screen/partner_studycafe_layout_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
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
                    decoration: const InputDecoration(labelText: '이용 시간(분)'),
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
                    decoration: const InputDecoration(labelText: '가격(원)'),
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
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isEnabled,
                    title: const Text('활성화'),
                    activeThumbColor: AppColors.primary,
                    onChanged: (bool value) => onAction(
                      PartnerStudyCafeLayoutAction.toggleUsageOptionEnabled(
                        index: index,
                        value: value,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onAction(
                    PartnerStudyCafeLayoutAction.removeUsageOption(index),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
