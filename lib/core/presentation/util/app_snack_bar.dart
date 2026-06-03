import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

enum AppSnackBarVariant { success, error }

class AppSnackBar {
  AppSnackBar._();

  static const Duration duration = Duration(milliseconds: 1500);

  static TextStyle get contentStyle => AppTextStyles.body.copyWith(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      );

  static Color backgroundColor(AppSnackBarVariant variant) {
    switch (variant) {
      case AppSnackBarVariant.success:
        return AppColors.signUpWithNaverButton;
      case AppSnackBarVariant.error:
        return Colors.red;
    }
  }

  static SnackBar snackBar(
    String message, {
    AppSnackBarVariant variant = AppSnackBarVariant.error,
  }) {
    return SnackBar(
      content: Text(message, style: contentStyle),
      duration: duration,
      backgroundColor: backgroundColor(variant),
      behavior: SnackBarBehavior.floating,
    );
  }

  static void show(
    BuildContext context,
    String message, {
    AppSnackBarVariant variant = AppSnackBarVariant.error,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar(message, variant: variant));
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message, variant: AppSnackBarVariant.success);
  }

  static void showError(BuildContext context, String message) {
    show(context, message, variant: AppSnackBarVariant.error);
  }
}
