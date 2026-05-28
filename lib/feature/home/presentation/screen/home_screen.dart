import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/home/core/model/home_store_item.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_category_section.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_header.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_recommended_store_list.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_search_bar.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_section_header.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_action.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  final HomeState state;
  final void Function(HomeAction action) onAction;
  final Future<void> Function() onRefresh;

  const HomeScreen({
    required this.state,
    required this.onAction,
    required this.onRefresh,
    super.key,
  });

  static const double _loadMoreScrollThreshold = 240;

  bool _onScrollNotification(ScrollNotification notification) {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return false;
    }
    if (notification.metrics.pixels <
        notification.metrics.maxScrollExtent - _loadMoreScrollThreshold) {
      return false;
    }
    onAction(const HomeAction.loadMoreStores());
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HomeHeader(),
                        const SizedBox(height: 16),
                        HomeSearchBar(
                          onTap: () =>
                              context.go('${Routes.home}/${Routes.search}'),
                        ),
                        const SizedBox(height: 20),
                        HomeCategorySection(
                          selectedCategory: state.selectedCategory,
                          onCategoryTap: (category) =>
                              onAction(HomeAction.selectCategory(category)),
                        ),
                        const SizedBox(height: 24),
                        const HomeSectionHeader(
                          title: '추천 업장',
                          subtitle: '근처 예약 가능한 가게를 확인해보세요!',
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  sliver: state.isLoading && state.recommendedStores.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        )
                      : HomeRecommendedStoreList(
                          stores: state.recommendedStores,
                          isLoadingMore: state.isLoadingMore,
                          onStoreTap: (HomeStoreItem store) {
                            context.push(
                              '${Routes.home}/information/${store.storeId}',
                            );
                          },
                          onBookmarkTap: (HomeStoreItem store) {
                            onAction(HomeAction.tapBookmark(store.storeId));
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
