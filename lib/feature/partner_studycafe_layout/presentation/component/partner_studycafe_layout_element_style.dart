import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element_type.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class PartnerStudyCafeLayoutElementStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final double borderRadius;

  const PartnerStudyCafeLayoutElementStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.borderRadius,
  });

  factory PartnerStudyCafeLayoutElementStyle.fromType(
    StudyCafeLayoutElementType type,
    bool isSelected,
  ) {
    final selectedBorder = isSelected ? AppColors.primary : AppColors.border;
    return switch (type) {
      StudyCafeLayoutElementType.partition => PartnerStudyCafeLayoutElementStyle(
        backgroundColor: AppColors.textSecondary.withValues(alpha: 0.18),
        borderColor: selectedBorder,
        textColor: AppColors.textPrimary,
        borderRadius: 4,
      ),
      StudyCafeLayoutElementType.door => PartnerStudyCafeLayoutElementStyle(
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        borderColor: AppColors.primary,
        textColor: AppColors.primary,
        borderRadius: 999,
      ),
      StudyCafeLayoutElementType.fixture => PartnerStudyCafeLayoutElementStyle(
        backgroundColor: AppColors.surfaceMuted,
        borderColor: selectedBorder,
        textColor: AppColors.textPrimary,
        borderRadius: 10,
      ),
    };
  }
}
