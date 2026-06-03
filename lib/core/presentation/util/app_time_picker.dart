import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppTimePicker {
  AppTimePicker._();

  static ThemeData _themedPickerTheme(BuildContext context) {
    final ThemeData base = Theme.of(context);
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: AppTextStyles.fontFamily,
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.textPrimary,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.white,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.white,
        hourMinuteColor: AppColors.signInTextField,
        hourMinuteTextColor: AppColors.textPrimary,
        hourMinuteTextStyle: AppTextStyles.body.copyWith(
          fontFamily: AppTextStyles.fontFamily,
          fontWeight: FontWeight.w600,
        ),
        dayPeriodColor: AppColors.signInTextField,
        dayPeriodTextColor: AppColors.textPrimary,
        dayPeriodTextStyle: AppTextStyles.body.copyWith(
          fontFamily: AppTextStyles.fontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Future<TimeOfDay?> show(
    BuildContext context, {
    required TimeOfDay initialTime,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: _themedPickerTheme(context),
          child: child!,
        );
      },
    );
  }
}
