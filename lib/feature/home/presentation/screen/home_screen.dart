import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/home/core/model/home_store_item.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_category_section.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_header.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_recommended_store_list.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_search_bar.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_section_header.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_action.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  final HomeState state;
  final void Function(HomeAction action) onAction;

  const HomeScreen({
    required this.state,
    required this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
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
              sliver: state.isLoading
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  : HomeRecommendedStoreList(
                      stores: state.recommendedStores,
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Align(
                  alignment: Alignment.center,
                  child: OutlinedButton(
                    onPressed: () {
                      onAction(const HomeAction.retryLoadHomeData());
                    },
                    child: const Text('업장 데이터 새로고침'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}