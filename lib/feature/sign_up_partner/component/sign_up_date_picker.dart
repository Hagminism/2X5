import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showSignUpDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  Locale locale = const Locale('ko', 'KR'),
}) {
  return showDatePicker(
    context: context,
    locale: locale,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: firstDate ?? DateTime(1900, 1, 1),
    lastDate: lastDate ?? DateTime(2100, 12, 31),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          dividerTheme: const DividerThemeData(
            color: Colors.transparent,
            thickness: 0,
            space: 0,
          ),
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            surface: AppColors.white,
            onSurface: AppColors.primary,
          ),
          dialogTheme: Theme.of(context).dialogTheme.copyWith(
            backgroundColor: AppColors.white,
          ),
          datePickerTheme: DatePickerThemeData(
            surfaceTintColor: Colors.transparent,
            backgroundColor: AppColors.white,
            headerBackgroundColor: AppColors.white,
            headerForegroundColor: AppColors.primary,
            dividerColor: AppColors.white,
            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.white;
              }
              if (states.contains(WidgetState.disabled)) {
                return AppColors.textSecondary;
              }
              return AppColors.primary;
            }),
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return Colors.transparent;
            }),
            dayOverlayColor: const WidgetStatePropertyAll(Colors.transparent),
            todayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.white;
              }
              return AppColors.primary;
            }),
            todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return Colors.transparent;
            }),
            todayBorder: BorderSide(
              color: AppColors.primary,
              width: 1,
            ),
            yearForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.white;
              }
              return AppColors.primary;
            }),
            yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return Colors.transparent;
            }),
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      );
    },
  );
}
