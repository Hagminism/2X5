import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerMyPageHeader extends StatelessWidget {
  final void Function() onTap;

  const PartnerMyPageHeader({
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '마이페이지',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: onTap,
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}
