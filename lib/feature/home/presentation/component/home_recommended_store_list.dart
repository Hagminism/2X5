import 'package:capstone_2026/feature/home/core/model/home_store_item.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_store_card.dart';
import 'package:flutter/material.dart';

class HomeRecommendedStoreList extends StatelessWidget {
  final List<HomeStoreItem> stores;
  final void Function(HomeStoreItem) onStoreTap;

  const HomeRecommendedStoreList({
    required this.stores,
    required this.onStoreTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Center(
            child: Text('표시할 업장이 없습니다.'),
          ),
        ),
      );
    }

    return SliverList.separated(
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return HomeStoreCard(
          name: store.name,
          subtitle: store.subtitle,
          rating: store.rating,
          category: store.category,
          imageUrl: store.imageUrl,
          showRating: store.showRating,
          onTap: () => onStoreTap(store),
        );
      },
      separatorBuilder: (_, _) => const SizedBox(height: 12),
    );
  }
}
