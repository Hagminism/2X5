import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_category_card.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_header.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_search_bar.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_section_container.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_section_header.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_store_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<_HomeCategoryItem> _categories = [
    _HomeCategoryItem('식당', Icons.restaurant_outlined),
    _HomeCategoryItem('카페', Icons.local_cafe_outlined),
    _HomeCategoryItem('미용실', Icons.content_cut_outlined),
    _HomeCategoryItem('스터디카페', Icons.menu_book_outlined),
  ];

  static const List<_StoreCardItem> _recommendedStores = [
    _StoreCardItem('s1', '돈블랑 여의도점', '고깃집 · 도보 5분', 4.47),
    _StoreCardItem('s2', '블루보틀 여의도 카페', '스페셜티 커피 · 도보 5분', 4.7),
    _StoreCardItem('s3', '아이디헤어 브라이튼여의도점', '헤어/메이크업 · 도보 11분', 4.6),
    _StoreCardItem('s4', '선셋 브런치 키친', '브런치 · 도보 6분', 4.9),
    _StoreCardItem('s5', '리프레시 네일 라운지', '네일아트 · 도보 9분', 4.7),
    _StoreCardItem('s6', '다온 스터디 라운지', '스터디카페 · 도보 13분', 4.5),
    _StoreCardItem('s7', '어반 바버샵', '남성 헤어 · 도보 10분', 4.6),
  ];

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
                    HomeHeader(
                      onNotificationTap: () => _showSoonMessage(
                        context,
                        '알림 화면은 다음 단계에서 연결될 예정입니다.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    HomeSearchBar(
                      onTap: () =>
                          context.go('${Routes.home}/${Routes.search}'),
                    ),
                    const SizedBox(height: 20),
                    HomeSectionContainer(
                      child: SizedBox(
                        height: 92,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final item = _categories[index];
                            return HomeCategoryCard(
                              title: item.title,
                              icon: item.icon,
                              onTap: () => _showSoonMessage(
                                context,
                                '${item.title} 카테고리 상세는 추후 연결됩니다.',
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const HomeSectionHeader(
                      title: '추천 업장',
                      subtitle: '지금 예약 가능한 인기 업장을 확인해보세요',
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              sliver: SliverList.separated(
                itemCount: _recommendedStores.length,
                itemBuilder: (context, index) {
                  final item = _recommendedStores[index];
                  return HomeStoreCard(
                    name: item.name,
                    subtitle: item.subtitle,
                    rating: item.rating,
                    onTap: () {
                      context.push(
                        '${Routes.home}/information/${item.storeId}',
                        extra: {
                          'name': item.name,
                          'subtitle': item.subtitle,
                          'rating': item.rating,
                        },
                      );
                    },
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(height: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSoonMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}

class _HomeCategoryItem {
  const _HomeCategoryItem(this.title, this.icon);
  final String title;
  final IconData icon;
}

class _StoreCardItem {
  const _StoreCardItem(this.storeId, this.name, this.subtitle, this.rating);
  final String storeId;
  final String name;
  final String subtitle;
  final double rating;
}