import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppDatePicker {
  AppDatePicker._();

  static const Locale locale = Locale('ko', 'KR');

  static ThemeData _themedPickerTheme(BuildContext context) {
    final ThemeData base = Theme.of(context);
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: AppTextStyles.fontFamily,
        bodyColor: AppColors.primary,
        displayColor: AppColors.primary,
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        surface: AppColors.white,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.white,
        headerHeadlineStyle: AppTextStyles.titleMedium.copyWith(
          fontFamily: AppTextStyles.fontFamily,
          color: AppColors.primary,
        ),
        weekdayStyle: AppTextStyles.caption.copyWith(
          fontFamily: AppTextStyles.fontFamily,
          color: AppColors.textSecondary,
        ),
        dayStyle: AppTextStyles.body.copyWith(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 14,
          color: AppColors.primary,
        ),
        yearStyle: AppTextStyles.body.copyWith(
          fontFamily: AppTextStyles.fontFamily,
          color: AppColors.primary,
        ),
      ),
    );
  }

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showDatePicker(
      context: context,
      locale: locale,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: _themedPickerTheme(context),
          child: child!,
        );
      },
    );
  }
}
