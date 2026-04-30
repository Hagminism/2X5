import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerFormTextField extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool isInteractive;
  final VoidCallback? onTap;

  const PartnerFormTextField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.isInteractive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textField = TextFormField(
      initialValue: initialValue,
      enabled: isInteractive,
      onChanged: isInteractive ? onChanged : null,
      onTap: isInteractive ? onTap : null,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTextStyles.body.copyWith(
        color: isInteractive ? AppColors.textPrimary : AppColors.textSecondary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: AppColors.signInTextField,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );

    if (onTap == null || isInteractive) {
      return textField;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AbsorbPointer(child: textField),
    );
  }
}
