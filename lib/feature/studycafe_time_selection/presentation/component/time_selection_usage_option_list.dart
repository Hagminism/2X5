import 'package:capstone_2026/core/domain/model/studycafe/studycafe_usage_option.dart';
import 'package:capstone_2026/feature/studycafe_time_selection/presentation/component/time_selection_usage_option_labels.dart';
import 'package:capstone_2026/feature/studycafe_time_selection/presentation/screen/time_selection_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class TimeSelectionUsageOptionList extends StatelessWidget {
  final List<StudyCafeUsageOption> options;
  final int? selectedDurationMinutes;
  final void Function(TimeSelectionAction action) onAction;

  const TimeSelectionUsageOptionList({
    super.key,
    required this.options,
    required this.selectedDurationMinutes,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: options.length,
      itemBuilder: (BuildContext context, int index) {
        final StudyCafeUsageOption option = options[index];
        final bool isSelected =
            selectedDurationMinutes == option.durationMinutes;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              onAction(
                TimeSelectionAction.tapSelectUsageOption(
                  durationMinutes: option.durationMinutes,
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : AppColors.white,
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeSelectionUsageOptionTitle(option),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          timeSelectionUsageOptionPriceLabel(option),
                          style: TextStyle(
                            fontSize: 15,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color:
                        isSelected ? AppColors.primary : AppColors.border,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
