import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppInfoDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String closeLabel;
  final String? ctaLabel;
  final void Function()? onCtaPressed;

  const AppInfoDialog({
    super.key,
    required this.title,
    this.message,
    this.closeLabel = '확인',
    this.ctaLabel,
    this.onCtaPressed,
  });

  bool get _hasCta => ctaLabel != null && onCtaPressed != null;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 10),
              Text(
                message!,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_hasCta) ...[
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      textStyle: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(closeLabel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      textStyle: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onCtaPressed!();
                    },
                    child: Text(ctaLabel!),
                  ),
                ] else
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      textStyle: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(closeLabel),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAppInfoDialog(
  BuildContext context, {
  required String title,
  String? message,
  String closeLabel = '확인',
  String? ctaLabel,
  void Function()? onCtaPressed,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) => AppInfoDialog(
      title: title,
      message: message,
      closeLabel: closeLabel,
      ctaLabel: ctaLabel,
      onCtaPressed: onCtaPressed,
    ),
  );
}
