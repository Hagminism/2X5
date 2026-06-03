import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

Future<T> runWithReviewSubmitLoading<T>(
  BuildContext context,
  Future<T> Function() action,
) async {
  if (!context.mounted) {
    return action();
  }

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 14),
                  Text(
                    '리뷰를 등록하는 중입니다...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  try {
    return await action();
  } finally {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
