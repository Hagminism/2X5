import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class PartnerStudyCafeLayoutEditorDeleteButton extends StatelessWidget {
  final String label;
  final void Function() onTap;

  const PartnerStudyCafeLayoutEditorDeleteButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.delete_outline_rounded),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.danger,
        side: BorderSide(color: AppColors.danger.withValues(alpha: 0.35)),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
