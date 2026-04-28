import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class DatePickerButton extends StatelessWidget {
  final String labelText;
  final void Function() onTap;

  const DatePickerButton({
    super.key,
    required this.labelText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          height: 56.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.signInTextField,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                size: 24,
                Icons.calendar_today_outlined,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  labelText,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
