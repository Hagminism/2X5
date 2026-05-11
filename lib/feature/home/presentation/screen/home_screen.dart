import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_category_card.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_header.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_search_bar.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_section_container.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_section_header.dart';
import 'package:capstone_2026/feature/home/presentation/component/home_store_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<_HomeCategoryItem> _categories = [
    _HomeCategoryItem('식당', Icons.restaurant_outlined),
    _HomeCategoryItem('카페', Icons.local_cafe_outlined),
    _HomeCategoryItem('미용실', Icons.content_cut_outlined),
    _HomeCategoryItem('스터디카페', Icons.menu_book_outlined),
  ];

  static const List<_StoreCardItem> _stores = [
    _StoreCardItem(storeId: 's1', name: '돈블랑 여의도점', subtitle: '고깃집 · 도보 5분', rating: 4.47, category: 'restaurant'),
    _StoreCardItem(storeId: 's2', name: '블루보틀 여의도 카페', subtitle: '스페셜티 커피 · 도보 5분', rating: 4.7, category: 'cafe'),
    _StoreCardItem(storeId: 's3', name: '아이디헤어 브라이튼여의도점', subtitle: '헤어/메이크업 · 도보 11분', rating: 4.6, category: 'salon'),
    _StoreCardItem(storeId: 's4', name: '선셋 브런치 키친', subtitle: '브런치 · 도보 6분', rating: 4.9, category: 'restaurant'),
    _StoreCardItem(storeId: 's5', name: '리프레시 네일 라운지', subtitle: '네일아트 · 도보 9분', rating: 4.7, category: 'salon'),
    _StoreCardItem(storeId: 's6', name: '다온 스터디 라운지', subtitle: '스터디카페 · 도보 13분', rating: 4.5, category: 'study_cafe'),
    _StoreCardItem(storeId: 's7', name: '어반 바버샵', subtitle: '남성 헤어 · 도보 10분', rating: 4.6, category: 'salon'),
  ];

  final Map<String, String> _coverImages = {};

  @override
  void initState() {
    super.initState();
    _fetchCoverImages();
  }

  Future<void> _fetchCoverImages() async {
    try {
      final ids = _stores.map((s) => s.storeId).toList();
      final res = await Supabase.instance.client
          .from('store_images')
          .select('store_id, image_url')
          .inFilter('store_id', ids)
          .eq('is_cover', true);

      if (!mounted) return;
      final map = <String, String>{};
      for (final row in res as List) {
        final sid = row['store_id']?.toString() ?? '';
        final url = row['image_url'] as String? ?? '';
        if (sid.isNotEmpty && url.isNotEmpty) map[sid] = url;
      }
      setState(() => _coverImages.addAll(map));
    } catch (e) {
      debugPrint('home cover images fetch error: $e');
    }
  }

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
                      onNotificationTap: () => context.push(
                        '${Routes.myPage}/${Routes.notifications}',
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
                itemCount: _stores.length,
                itemBuilder: (context, index) {
                  final item = _stores[index];
                  return HomeStoreCard(
                    name: item.name,
                    subtitle: item.subtitle,
                    rating: item.rating,
                    category: item.category,
                    imageUrl: _coverImages[item.storeId],
                    onTap: () {
                       //스터디 카페 판별 로직
                      final String detectedCategory = item.subtitle.contains('스터디카페')
                          ? '스터디카페'
                          : '일반';
                      context.push(
                        '${Routes.home}/information/${item.storeId}',
                        extra: {
                          'name': item.name,
                          'subtitle': item.subtitle,
                          'rating': item.rating,
                          'category': detectedCategory,
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
  const _StoreCardItem({
    required this.storeId,
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.category,
  });
  final String storeId;
  final String name;
  final String subtitle;
  final double rating;
  final String category;
}
