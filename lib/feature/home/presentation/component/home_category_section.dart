import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_category_card.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_section_container.dart';
import 'package:flutter/material.dart';

class HomeCategorySection extends StatelessWidget {
  final void Function(StoreCategory) onCategoryTap;

  const HomeCategorySection({
    required this.onCategoryTap,
    super.key,
  });

  IconData _categoryIcon(StoreCategory category) {
    switch (category) {
      case StoreCategory.restaurant:
        return Icons.restaurant_outlined;
      case StoreCategory.cafe:
        return Icons.local_cafe_outlined;
      case StoreCategory.studyCafe:
        return Icons.menu_book_outlined;
      case StoreCategory.salon:
        return Icons.content_cut_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeSectionContainer(
      child: SizedBox(
        height: 92,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: StoreCategory.values.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final category = StoreCategory.values[index];
            return HomeCategoryCard(
              title: category.displayName,
              icon: _categoryIcon(category),
              onTap: () => onCategoryTap(category),
            );
          },
        ),
      ),
    );
  }
}
