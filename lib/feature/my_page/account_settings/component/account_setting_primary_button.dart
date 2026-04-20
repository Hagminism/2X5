import 'package:flutter/material.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';

class AccountSettingPrimaryButton extends StatelessWidget {
  final Widget leading;
  final String title;
  final BorderRadius? borderRadius;
  final bool? showArrow;
  final Color? titleColor;
  final Color? arrowColor;
  final void Function() onTap;

  const AccountSettingPrimaryButton({
    super.key,
    required this.leading,
    required this.title,
    required this.onTap,
    this.borderRadius,
    this.showArrow,
    this.titleColor,
    this.arrowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: (borderRadius != null)
            ? borderRadius
            : BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
          ),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: (borderRadius != null)
                  ? borderRadius
                  : BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.securitySectionButtonBorder,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  leading,
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                      color: (titleColor != null) ? titleColor : null,
                    ),
                  ),
                  if (showArrow == true) Spacer(),
                  if (showArrow == true)
                    Icon(size: 12, Icons.arrow_forward_ios, color: arrowColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
