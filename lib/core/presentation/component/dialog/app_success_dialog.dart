import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppSuccessDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? message;
  final Widget? body;
  final String confirmLabel;
  final VoidCallback onConfirm;

  const AppSuccessDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.message,
    this.body,
    this.confirmLabel = '확인',
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary,
              ),
            ],
            if (message != null) ...[
              const SizedBox(height: 20),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
            if (body != null) ...[
              const SizedBox(height: 20),
              body!,
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              text: confirmLabel,
              onTap: onConfirm,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAppSuccessDialog(
  BuildContext context, {
  required String title,
  String? subtitle,
  String? message,
  Widget? body,
  String confirmLabel = '확인',
  required VoidCallback onConfirm,
  bool barrierDismissible = false,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext dialogContext) => AppSuccessDialog(
      title: title,
      subtitle: subtitle,
      message: message,
      body: body,
      confirmLabel: confirmLabel,
      onConfirm: () {
        Navigator.of(dialogContext).pop();
        onConfirm();
      },
    ),
  );
}
