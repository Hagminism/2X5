import 'dart:math' as math;

import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, List<Map<String, dynamic>>> _categorizedResults = {};
  bool _isLoading = false;
  bool _hasSearched = false;
  double? _selectedRadiusMeters;
  Set<String> _selectedCategories = {};
  _SearchSortOption _selectedSortOption = _SearchSortOption.defaultOrder;

  static const double _baseLatitude = 37.5826;
  static const double _baseLongitude = 127.0106;
  static const List<_RadiusFilterOption> _radiusFilterOptions = [
    _RadiusFilterOption(label: '전체', radiusMeters: null),
    _RadiusFilterOption(label: '500m', radiusMeters: 500),
    _RadiusFilterOption(label: '1km', radiusMeters: 1000),
    _RadiusFilterOption(label: '3km', radiusMeters: 3000),
  ];
  static const List<_CategoryFilterOption> _categoryFilterOptions = [
    _CategoryFilterOption(label: '식당', value: 'restaurant'),
    _CategoryFilterOption(label: '카페', value: 'cafe'),
    _CategoryFilterOption(label: '스터디카페', value: 'study_cafe'),
    _CategoryFilterOption(label: '미용실', value: 'salon'),
  ];

  static const Map<String, String> categoryEmojis = {
    'restaurant': '🍽',
    'cafe': '☕',
    'study_cafe': '📚',
    'salon': '✂',
  };

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

  List<Map<String, dynamic>> _filterByRadius(
    List<Map<String, dynamic>> stores,
  ) {
    final radiusMeters = _selectedRadiusMeters;
    if (radiusMeters == null) {
      return stores;
    }

    return stores.where((store) {
      final distance = _calcDistance(store);
      return distance != null && distance <= radiusMeters;
    }).toList();
  }

  List<Map<String, dynamic>> _filterByCategory(
    List<Map<String, dynamic>> stores,
  ) {
    if (_selectedCategories.isEmpty) {
      return stores;
    }

    return stores.where((store) {
      final category = store['category']?.toString();
      return category != null && _selectedCategories.contains(category);
    }).toList();
  }

  void _applyFilters() {
    final radiusFilteredStores = _filterByRadius(_searchResults);
    final filteredStores = _filterByCategory(radiusFilteredStores);
    _sortStores(filteredStores);
    _categorizedResults = _groupByCategory(filteredStores);
  }

  void _sortStores(List<Map<String, dynamic>> stores) {
    switch (_selectedSortOption) {
      case _SearchSortOption.defaultOrder:
        return;
      case _SearchSortOption.rating:
        stores.sort((a, b) {
          final aRating = (a['rating'] as num?)?.toDouble() ?? 0;
          final bRating = (b['rating'] as num?)?.toDouble() ?? 0;
          return bRating.compareTo(aRating);
        });
        break;
      case _SearchSortOption.nearest:
        stores.sort((a, b) {
          final aDistance = _calcDistance(a) ?? double.infinity;
          final bDistance = _calcDistance(b) ?? double.infinity;
          return aDistance.compareTo(bDistance);
        });
        break;
    }
  }

  Future<void> _search(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      setState(() {
        _searchResults = [];
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
      final coverImageUrls = await _fetchCoverImageUrls(results);
      final resultsWithImages = results.map((store) {
        final storeId = store['id']?.toString() ?? '';
        return {
          ...store,
          'image_url': coverImageUrls[storeId],
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        _searchResults = resultsWithImages;
        _applyFilters();
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

  Future<Map<String, String>> _fetchCoverImageUrls(
    List<Map<String, dynamic>> stores,
  ) async {
    final storeIds = stores
        .map((store) => store['id']?.toString() ?? '')
        .where((storeId) => storeId.isNotEmpty)
        .toList();
    if (storeIds.isEmpty) {
      return const {};
    }

    try {
      final response = await Supabase.instance.client
          .from('store_images')
          .select('store_id, image_url, is_cover, sort_order')
          .inFilter('store_id', storeIds)
          .order('is_cover', ascending: false)
          .order('sort_order', ascending: true);

      final imageUrlsByStoreId = <String, String>{};
      for (final row in response as List) {
        final storeId = row['store_id']?.toString() ?? '';
        final imageUrl = row['image_url']?.toString() ?? '';
        if (storeId.isEmpty ||
            imageUrl.isEmpty ||
            imageUrlsByStoreId.containsKey(storeId)) {
          continue;
        }
        imageUrlsByStoreId[storeId] = imageUrl;
      }
      return imageUrlsByStoreId;
    } catch (e) {
      debugPrint('search cover images fetch error: $e');
      return const {};
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

    context.push(
      '${Routes.map}/${Routes.search}/search-store-information/$storeId',
    );
  }

  double? _calcDistance(Map<String, dynamic> store) {
    final lat = (store['latitude'] as num?)?.toDouble();
    final lng = (store['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    return Geolocator.distanceBetween(
      _baseLatitude,
      _baseLongitude,
      lat,
      lng,
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  String _walkingTime(double meters) {
    final minutes = math.max(1, (meters / 83.3).ceil());
    return '도보 $minutes분';
  }

  String _categoryDisplayLabel(String category) {
    final label = categoryLabels[category] ?? category;
    final emoji = categoryEmojis[category];
    if (emoji == null || emoji.isEmpty) return label;
    return '$emoji $label';
  }

  void _changeRadiusFilter(double? radiusMeters) {
    setState(() {
      _selectedRadiusMeters = radiusMeters;
      _applyFilters();
    });
  }

  void _changeSortOption(_SearchSortOption sortOption) {
    setState(() {
      _selectedSortOption = sortOption;
      _applyFilters();
    });
  }

  void _changeCategoryFilters(Set<String> categories) {
    setState(() {
      _selectedCategories = categories;
      _applyFilters();
    });
  }

  bool get _hasActiveFilter =>
      _selectedRadiusMeters != null ||
      _selectedCategories.isNotEmpty ||
      _selectedSortOption != _SearchSortOption.defaultOrder;

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _SearchFilterBottomSheet(
          radiusOptions: _radiusFilterOptions,
          categoryOptions: _categoryFilterOptions,
          selectedRadiusMeters: _selectedRadiusMeters,
          selectedCategories: _selectedCategories,
          selectedSortOption: _selectedSortOption,
          onRadiusSelected: (radiusMeters) {
            _changeRadiusFilter(radiusMeters);
            Navigator.pop(context);
          },
          onCategoriesChanged: _changeCategoryFilters,
          onSortSelected: (sortOption) {
            _changeSortOption(sortOption);
            Navigator.pop(context);
          },
        );
      },
    );
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
                      onFilterTap: _showFilterBottomSheet,
                      hasActiveFilter: _hasActiveFilter,
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
        final categoryLabel = _categoryDisplayLabel(category);

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
            ...stores.map((store) {
              final distance = _calcDistance(store);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SearchResultCard(
                  store: store,
                  categoryLabel: _categoryDisplayLabel(
                    store['category']?.toString() ?? '',
                  ),
                  distanceLabel: distance == null
                      ? null
                      : _formatDistance(distance),
                  walkingTimeLabel: distance == null
                      ? null
                      : _walkingTime(distance),
                  onTap: () => _openStoreDetail(store),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

enum _SearchSortOption {
  defaultOrder(label: '기본순'),
  rating(label: '별점순'),
  nearest(label: '가까운 순')
  ;

  const _SearchSortOption({required this.label});

  final String label;
}

class _RadiusFilterOption {
  const _RadiusFilterOption({
    required this.label,
    required this.radiusMeters,
  });

  final String label;
  final double? radiusMeters;
}

class _CategoryFilterOption {
  const _CategoryFilterOption({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _SearchFilterBottomSheet extends StatefulWidget {
  const _SearchFilterBottomSheet({
    required this.radiusOptions,
    required this.categoryOptions,
    required this.selectedRadiusMeters,
    required this.selectedCategories,
    required this.selectedSortOption,
    required this.onRadiusSelected,
    required this.onCategoriesChanged,
    required this.onSortSelected,
  });

  final List<_RadiusFilterOption> radiusOptions;
  final List<_CategoryFilterOption> categoryOptions;
  final double? selectedRadiusMeters;
  final Set<String> selectedCategories;
  final _SearchSortOption selectedSortOption;
  final ValueChanged<double?> onRadiusSelected;
  final ValueChanged<Set<String>> onCategoriesChanged;
  final ValueChanged<_SearchSortOption> onSortSelected;

  @override
  State<_SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<_SearchFilterBottomSheet> {
  late Set<String> _selectedCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategories = Set<String>.from(widget.selectedCategories);
  }

  void _clearCategories() {
    setState(() {
      _selectedCategories = {};
    });
    widget.onCategoriesChanged(_selectedCategories);
  }

  void _toggleCategory(String category) {
    final nextCategories = Set<String>.from(_selectedCategories);
    if (nextCategories.contains(category)) {
      nextCategories.remove(category);
    } else {
      nextCategories.add(category);
    }

    setState(() {
      _selectedCategories = nextCategories;
    });
    widget.onCategoriesChanged(nextCategories);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '검색 필터',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 18),
            const _FilterSectionTitle(title: '거리'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.radiusOptions.map((option) {
                return _FilterOptionChip(
                  label: option.label,
                  isSelected:
                      option.radiusMeters == widget.selectedRadiusMeters,
                  onTap: () => widget.onRadiusSelected(option.radiusMeters),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            const _FilterSectionTitle(title: '업종'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterOptionChip(
                  label: '전체',
                  isSelected: _selectedCategories.isEmpty,
                  onTap: _clearCategories,
                ),
                ...widget.categoryOptions.map((option) {
                  return _FilterOptionChip(
                    label: option.label,
                    isSelected: _selectedCategories.contains(option.value),
                    onTap: () => _toggleCategory(option.value),
                  );
                }),
              ],
            ),
            const SizedBox(height: 22),
            const _FilterSectionTitle(title: '정렬'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _SearchSortOption.values.map((option) {
                return _FilterOptionChip(
                  label: option.label,
                  isSelected: option == widget.selectedSortOption,
                  onTap: () => widget.onSortSelected(option),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSectionTitle extends StatelessWidget {
  const _FilterSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.label.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FilterOptionChip extends StatelessWidget {
  const _FilterOptionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelStyle: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.w700,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceMuted,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }
}

class _FilterIconButton extends StatelessWidget {
  const _FilterIconButton({
    required this.onTap,
    required this.isActive,
  });

  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.tune_rounded,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
          if (isActive)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      tooltip: '필터',
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.onSubmitted,
    required this.onSearchTap,
    required this.onFilterTap,
    required this.hasActiveFilter,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;
  final bool hasActiveFilter;

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
          _FilterIconButton(
            onTap: onFilterTap,
            isActive: hasActiveFilter,
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
    required this.distanceLabel,
    required this.walkingTimeLabel,
    required this.onTap,
  });

  final Map<String, dynamic> store;
  final String categoryLabel;
  final String? distanceLabel;
  final String? walkingTimeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final storeName = store['name']?.toString() ?? '이름 없음';
    final imageUrl = store['image_url']?.toString();
    final ownerId = store['owner_id']?.toString().trim();
    final hasOwner = ownerId != null && ownerId.isNotEmpty;
    final rating = (store['rating'] as num?)?.toDouble();
    final shouldShowRating = hasOwner && rating != null;
    final hasMeta =
        categoryLabel.isNotEmpty ||
        distanceLabel != null ||
        walkingTimeLabel != null ||
        shouldShowRating;

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
              clipBehavior: Clip.antiAlias,
              child: (imageUrl == null || imageUrl.isEmpty)
                  ? const Icon(
                      Icons.storefront_rounded,
                      color: AppColors.textPrimary,
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.storefront_rounded,
                        color: AppColors.textPrimary,
                      ),
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
                  if (hasMeta) ...[
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (categoryLabel.isNotEmpty)
                          _MetaChip(label: categoryLabel),
                        if (distanceLabel != null)
                          _MetaChip(label: distanceLabel!),
                        if (walkingTimeLabel != null)
                          _MetaChip(label: walkingTimeLabel!),
                        if (shouldShowRating)
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
                color: AppColors.primary,
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
