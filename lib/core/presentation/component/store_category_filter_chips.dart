import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class StoreCategoryFilterChips extends StatelessWidget {
  const StoreCategoryFilterChips({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  /// null = 전체, 그 외 = stores.category DB 값 (restaurant, cafe, ...)
  final String? selected;
  final ValueChanged<String?> onSelect;

  static const _items = [
    (label: '전체', value: null as String?, emoji: '🗺'),
    (label: '식당', value: 'restaurant', emoji: '🍽'),
    (label: '카페', value: 'cafe', emoji: '☕'),
    (label: '스터디카페', value: 'study_cafe', emoji: '📚'),
    (label: '미용실', value: 'salon', emoji: '✂'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _items.map((item) {
          final isSelected = selected == item.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(item.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}