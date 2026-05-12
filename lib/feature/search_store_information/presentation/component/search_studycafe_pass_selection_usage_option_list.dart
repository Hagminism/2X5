import 'package:capstone_2026/core/domain/model/studycafe/studycafe_usage_option.dart';
import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_studycafe_pass_selection_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

String searchStudycafePassUsageOptionTitle(StudyCafeUsageOption option) {
  final minutes = option.durationMinutes;
  if (minutes <= 0) {
    return '이용권';
  }
  if (minutes % 60 == 0) {
    final hours = minutes ~/ 60;
    return '$hours시간 이용권';
  }
  return '$minutes분 이용권';
}

String searchStudycafePassUsageOptionPriceLabel(StudyCafeUsageOption option) {
  return '${option.price}원';
}

class SearchStudycafePassSelectionUsageOptionList extends StatelessWidget {
  final List<StudyCafeUsageOption> options;
  final int? selectedDurationMinutes;
  final void Function(SearchStudycafePassSelectionAction action) onAction;

  const SearchStudycafePassSelectionUsageOptionList({
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
                SearchStudycafePassSelectionAction.tapSelectUsageOption(
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
                          searchStudycafePassUsageOptionTitle(option),
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
                          searchStudycafePassUsageOptionPriceLabel(option),
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
