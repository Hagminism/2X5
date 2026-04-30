import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class GalleryPickerButton extends StatelessWidget {
  final String labelText;
  final void Function() onTap;

  const GalleryPickerButton({
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.signInTextField,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.photo_library_outlined,
                size: 24,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 16),
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
