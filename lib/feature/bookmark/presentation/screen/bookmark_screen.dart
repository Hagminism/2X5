import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/bookmark/presentation/component/bookmark_empty_state.dart';
import 'package:capstone_2026/feature/bookmark/presentation/component/bookmark_filter_chips.dart';
import 'package:capstone_2026/feature/bookmark/presentation/component/bookmark_page_header.dart';
import 'package:capstone_2026/feature/bookmark/presentation/component/bookmark_store_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  static const List<String> _filters = ['전체', '식당', '카페', '미용실', '스터디카페'];
  String _selectedFilter = '전체';

  final List<_BookmarkStoreItem> _bookmarkStores = [
    _BookmarkStoreItem(
      id: 's1',
      name: '돈블랑 여의도점',
      category: '식당',
      subtitle: '도보 5분 · 영업 중',
      rating: 4.47,
      reviewCount: 280,
    ),
    _BookmarkStoreItem(
      id: 's2',
      name: '블루보틀 여의도 카페',
      category: '카페',
      subtitle: '도보 5분 · 영업 중',
      rating: 4.7,
      reviewCount: 96,
    ),
    _BookmarkStoreItem(
      id: 's3',
      name: '아이디헤어 여의도점',
      category: '미용실',
      subtitle: '도보 11분 · 영업 종료',
      rating: 4.6,
      reviewCount: 83,
    ),
    _BookmarkStoreItem(
      id: 's4',
      name: '다온 스터디 라운지',
      category: '스터디카페',
      subtitle: '도보 13분 · 영업 중',
      rating: 4.5,
      reviewCount: 57,
    ),
  ];

  List<_BookmarkStoreItem> get _visibleStores {
    if (_selectedFilter == '전체') {
      return _bookmarkStores;
    }
    return _bookmarkStores
        .where((item) => item.category == _selectedFilter)
        .toList();
  }

  void _removeBookmark(String id) {
    setState(() {
      _bookmarkStores.removeWhere((item) => item.id == id);
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('저장 목록에서 제거했습니다.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final visibleStores = _visibleStores;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BookmarkPageHeader(),
              const SizedBox(height: 14),
              BookmarkFilterChips(
                filters: _filters,
                selectedFilter: _selectedFilter,
                onFilterSelected: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (visibleStores.isEmpty)
                BookmarkEmptyState(
                  onExploreTap: () => context.go(Routes.home),
                )
              else
                Column(
                  children: visibleStores
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: BookmarkStoreCard(
                            name: item.name,
                            category: item.category,
                            subtitle: item.subtitle,
                            rating: item.rating,
                            reviewCount: item.reviewCount,
                            onTap: () => context.go(
                              '${Routes.bookmark}/store/${item.id}',
                            ),
                            onBookmarkTap: () => _removeBookmark(item.id),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookmarkStoreItem {
  const _BookmarkStoreItem({
    required this.id,
    required this.name,
    required this.category,
    required this.subtitle,
    required this.rating,
    required this.reviewCount,
  });

  final String id;
  final String name;
  final String category;
  final String subtitle;
  final double rating;
  final int reviewCount;
}
