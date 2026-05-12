import 'package:capstone_2026/feature/studycafe_time_selection/presentation/screen/time_selection_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class TimeSelectionSubmitBar extends StatelessWidget {
  final bool enabled;
  final bool isSubmitting;
  final void Function(TimeSelectionAction action) onAction;

  const TimeSelectionSubmitBar({
    super.key,
    required this.enabled,
    required this.isSubmitting,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: !enabled || isSubmitting
                ? null
                : () {
                    onAction(const TimeSelectionAction.tapSubmit());
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.border,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.white,
                    ),
                  )
                : const Text(
                    '결제하고 이용 시작',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
