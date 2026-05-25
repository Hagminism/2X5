import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class BookmarkFilterChips extends StatelessWidget {
  const BookmarkFilterChips({
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
    super.key,
  });

  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map(
              (filter) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: selectedFilter == filter,
                  showCheckmark: false,
                  onSelected: (_) => onFilterSelected(filter),
                  selectedColor: AppColors.primary.withValues(alpha: 0.14),
                  backgroundColor: AppColors.surfaceMuted,
                  side: const BorderSide(color: AppColors.border),
                  labelStyle: TextStyle(
                    color: selectedFilter == filter
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
