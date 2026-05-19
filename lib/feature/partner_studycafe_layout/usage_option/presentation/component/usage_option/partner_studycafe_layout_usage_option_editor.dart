import 'package:capstone_2026/feature/partner_studycafe_layout/usage_option/presentation/component/usage_option/partner_studycafe_layout_section_card.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/usage_option/presentation/component/usage_option/partner_studycafe_layout_usage_option_tile.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/usage_option/presentation/screen/partner_studycafe_usage_option_action.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/usage_option/presentation/screen/partner_studycafe_usage_option_state.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerStudyCafeUsageOptionEditor extends StatelessWidget {
  final PartnerStudyCafeUsageOptionState state;
  final void Function(PartnerStudyCafeUsageOptionAction action) onAction;

  const PartnerStudyCafeUsageOptionEditor({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return PartnerStudyCafeLayoutSectionCard(
      title: '이용권 목록',
      trailing: TextButton.icon(
        onPressed: () => onAction(
          const PartnerStudyCafeUsageOptionAction.addUsageOption(),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('추가'),
      ),
      child: Column(
        children: [
          if (state.usageOptions.isEmpty)
            Text('등록된 이용권이 없습니다.', style: AppTextStyles.bodySecondary),
          for (var i = 0; i < state.usageOptions.length; i++) ...[
            PartnerStudyCafeUsageOptionTile(
              index: i,
              durationMinutes: state.usageOptions[i].durationMinutes,
              price: state.usageOptions[i].price,
              isEnabled: state.usageOptions[i].isEnabled,
              onAction: onAction,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
