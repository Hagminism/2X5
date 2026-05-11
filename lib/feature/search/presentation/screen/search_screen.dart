import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String, List<Map<String, dynamic>>> _categorizedResults = {};
  bool _isLoading = false;
  bool _hasSearched = false;

  static const Map<String, String> categoryLabels = {
    'restaurant': '식당',
    'cafe': '카페',
    'study_cafe': '스터디카페',
    'salon': '미용실',
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, List<Map<String, dynamic>>> _groupByCategory(
    List<Map<String, dynamic>> stores,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final store in stores) {
      final category = store['category']?.toString() ?? 'restaurant';
      grouped.putIfAbsent(category, () => []).add(store);
    }

    return grouped;
  }

  Future<void> _search(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      setState(() {
        _categorizedResults = {};
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('stores')
          .select()
          .or(
            'name.ilike.%$trimmedQuery%,address.ilike.%$trimmedQuery%,naver_place_id.ilike.%$trimmedQuery%',
          )
          .limit(50);

      final results = List<Map<String, dynamic>>.from(response);
      final grouped = _groupByCategory(results);

      if (!mounted) return;

      setState(() {
        _categorizedResults = grouped;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('검색 오류: $e')),
      );
    }
  }

  void _openStoreDetail(Map<String, dynamic> store) {
    final storeId = store['id']?.toString() ?? '';
    if (storeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('업장 정보를 찾을 수 없습니다.')),
      );
      return;
    }

    context.push('${Routes.home}/information/$storeId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.textPrimary,
                    tooltip: '뒤로가기',
                  ),
                  Expanded(
                    child: _SearchInput(
                      controller: _controller,
                      onSubmitted: _search,
                      onSearchTap: () => _search(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_categorizedResults.isEmpty) {
      return _SearchEmptyState(hasSearched: _hasSearched);
    }

    final categories = _categorizedResults.keys.toList();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: categories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final category = categories[index];
        final stores = _categorizedResults[category]!;
        final categoryLabel = categoryLabels[category] ?? category;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$categoryLabel ${stores.length}',
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ...stores.map(
              (store) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SearchResultCard(
                  store: store,
                  categoryLabel:
                      categoryLabels[store['category']?.toString()] ?? '',
                  onTap: () => _openStoreDetail(store),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.onSubmitted,
    required this.onSearchTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '업장, 지역, 키워드로 검색',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4B5563),
                ),
                border: InputBorder.none,
                isCollapsed: true,
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
            ),
          ),
          IconButton(
            onPressed: onSearchTap,
            icon: const Icon(Icons.arrow_forward_rounded),
            color: AppColors.primary,
            tooltip: '검색',
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.store,
    required this.categoryLabel,
    required this.onTap,
  });

  final Map<String, dynamic> store;
  final String categoryLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final storeName = store['name']?.toString() ?? '이름 없음';
    final storeAddress = store['address']?.toString() ?? '주소 없음';
    final rating = (store['rating'] as num?)?.toDouble();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120F172A),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    storeAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(fontSize: 13),
                  ),
                  if (categoryLabel.isNotEmpty || rating != null) ...[
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        if (categoryLabel.isNotEmpty)
                          _MetaChip(label: categoryLabel),
                        if (categoryLabel.isNotEmpty && rating != null)
                          const SizedBox(width: 6),
                        if (rating != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({required this.hasSearched});

  final bool hasSearched;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 34,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearched ? '검색 결과가 없습니다' : '업장을 검색해보세요',
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasSearched
                  ? '다른 키워드나 지역명으로 다시 찾아보세요'
                  : '이름, 주소, 키워드로 업장을 찾을 수 있어요',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
