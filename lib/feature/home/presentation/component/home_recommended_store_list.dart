import 'package:capstone_2026/feature/home/core/model/home_store_item.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_store_card.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class HomeRecommendedStoreList extends StatelessWidget {
  final List<HomeStoreItem> stores;
  final bool isLoadingMore;
  final void Function(HomeStoreItem) onStoreTap;
  final void Function(HomeStoreItem) onBookmarkTap;

  const HomeRecommendedStoreList({
    required this.stores,
    required this.onStoreTap,
    required this.onBookmarkTap,
    this.isLoadingMore = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Center(
            child: Text(
              '표시할 업장이 없습니다.',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.1,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return SliverList.separated(
      itemCount: stores.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= stores.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }
        final store = stores[index];
        return HomeStoreCard(
          key: ValueKey(store.storeId),
          name: store.name,
          subtitle: store.subtitle,
          rating: store.rating,
          category: store.category,
          imageUrl: store.imageUrl,
          isBookmarked: store.isBookmarked,
          onTap: () => onStoreTap(store),
          onBookmarkTap: () => onBookmarkTap(store),
        );
      },
      separatorBuilder: (_, _) => const SizedBox(height: 12),
    );
  }
}
