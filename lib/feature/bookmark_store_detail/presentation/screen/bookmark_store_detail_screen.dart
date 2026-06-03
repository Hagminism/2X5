import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/di/di_setup.dart';
import 'package:capstone_2026/feature/bookmark_store_detail/presentation/component/bookmark_store_detail_bottom_bar.dart';
import 'package:capstone_2026/feature/bookmark_store_detail/presentation/component/bookmark_store_detail_image_carousel.dart';
import 'package:capstone_2026/feature/bookmark_store_detail/presentation/component/bookmark_store_detail_info_section.dart';
import 'package:capstone_2026/feature/store_detail/data/store_detail_data.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/store_detail.dart';
import 'package:capstone_2026/feature/store_detail/domain/service/store_review_service.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_tab_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:capstone_2026/feature/store_detail/data/data_source/naver_store_search_data_source.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

class BookmarkStoreDetailScreen extends StatefulWidget {
  const BookmarkStoreDetailScreen({
    required this.storeId,
    super.key,
  });

  final String storeId;

  @override
  State<BookmarkStoreDetailScreen> createState() =>
      _BookmarkStoreDetailScreenState();
}

class _BookmarkStoreDetailScreenState extends State<BookmarkStoreDetailScreen> {
  int _selectedTab = 0;
  bool _isReviewLoading = true;
  List<InternalReview> _reviews = const [];

  bool _isNaverDataLoading = false;
  List<Map<String, dynamic>> _naverMenus = const [];
  List<Map<String, dynamic>> _naverReviews = const [];

  StoreReviewService get _storeReviewService => getIt<StoreReviewService>();
  NaverStoreSearchDataSource get _naverStoreSearchDataSource =>
      getIt<NaverStoreSearchDataSource>();

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  @override
  void didUpdateWidget(covariant BookmarkStoreDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storeId != widget.storeId) {
      _selectedTab = 0;
      _loadStoreData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = storeDetailMockMap[widget.storeId] ?? defaultStoreDetail;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                const BookmarkStoreDetailImageCarousel(),
                Positioned(
                  left: 12,
                  right: 12,
                  top: 48,
                  child: Row(
                    children: [
                      _CircleIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      _CircleIconButton(
                        icon: Icons.home_outlined,
                        onTap: () => context.go(Routes.home),
                      ),
                      const Spacer(),
                      _CircleIconButton(
                        icon: Icons.search_rounded,
                        onTap: () => _showMessage('검색 기능은 준비 중입니다.'),
                      ),
                      const SizedBox(width: 8),
                      _CircleIconButton(
                        icon: Icons.bookmark_border_rounded,
                        onTap: () => _showMessage('북마크 기능은 준비 중입니다.'),
                      ),
                      const SizedBox(width: 8),
                      _CircleIconButton(
                        icon: Icons.share_outlined,
                        onTap: () => _showMessage('공유 기능은 준비 중입니다.'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: BookmarkStoreDetailInfoSection(
              storeName: data.name,
              category: data.category,
              rating: data.rating,
              reviewCount: data.reviewCount,
              description: data.description,
              locationText: data.location,
              priceText: data.priceRange,
              timeText: data.openHours,
              tags: data.tags,
              onCallTap: () => _showMessage('전화 연결 기능은 준비 중입니다.'),
            ),
          ),
          SliverToBoxAdapter(
            child: StoreDetailTabSection(
              selectedTab: _selectedTab,
              storeName: data.name,
              location: data.location,
              naverPlaceId: data.naverPlaceId,
              googleSearchQuery: data.googleSearchQuery,
              reviews: _reviews,
              isReviewLoading: _isReviewLoading,
              isNaverDataLoading: _isNaverDataLoading,
              naverMenus: _naverMenus,
              naverReviews: _naverReviews,
              stampStatus: null,
              onSubmitReview: (result) => _submitReview(data, result),
              onTapNaverReview: () => _openNaverReview(data),
              onTapGoogleReview: () => _openGoogleReview(data),
              onTabSelected: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: BookmarkStoreDetailBottomBar(
        onBookmarkTap: () => _showMessage('북마크 기능은 준비 중입니다.'),
        onCallTap: () => _showMessage('전화 연결 기능은 준비 중입니다.'),
        onReserveTap: () => _showMessage('예약 화면은 다음 단계에서 연결됩니다.'),
      ),
    );
  }

  Future<void> _loadStoreData() async {
    setState(() {
      _isReviewLoading = true;
      _isNaverDataLoading = true;
    });

    final data = storeDetailMockMap[widget.storeId] ?? defaultStoreDetail;

    Future<void> loadNaverData() async {
      if (data.naverPlaceId.isEmpty) return;
      try {
        final (menus, reviews) = await (
          _naverStoreSearchDataSource.fetchStoreMenus(
            placeId: data.naverPlaceId,
          ),
          _naverStoreSearchDataSource.fetchStoreReviews(
            placeId: data.naverPlaceId,
          ),
        ).wait;

        if (!mounted) return;
        setState(() {
          _naverMenus = menus;
          _naverReviews = reviews;
          _isNaverDataLoading = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _isNaverDataLoading = false;
        });
      }
    }

    try {
      final (reviews, _) = await (
        _storeReviewService.loadStoreReviews(storeId: widget.storeId),
        loadNaverData(),
      ).wait;

      if (!mounted) {
        return;
      }

      setState(() {
        _reviews = reviews;
        _isReviewLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isReviewLoading = false;
        _isNaverDataLoading = false;
      });
      _showMessage('리뷰를 불러오는 중 오류가 발생했습니다.');
    }
  }

  Future<void> _submitReview(
    StoreDetail data,
    ReviewWriteResult result,
  ) async {
    try {
      final createdReview = await _storeReviewService.submitReview(
        storeId: widget.storeId,
        storeName: data.name,
        review: result,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _reviews = [createdReview, ..._reviews];
      });

      _showMessage(
        '리뷰가 등록되었습니다.',
        variant: AppSnackBarVariant.success,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage('리뷰 등록 중 오류가 발생했습니다.');
    }
  }

  void _showMessage(
    String message, {
    AppSnackBarVariant variant = AppSnackBarVariant.error,
  }) {
    AppSnackBar.show(context, message, variant: variant);
  }

  Future<void> _openNaverReview(StoreDetail data) async {
    final target = await _storeReviewService.getNaverReviewLinkTarget(
      storeName: data.name,
      location: data.location,
      placeId: data.naverPlaceId,
    );

    try {
      if (target.appUri != null && await canLaunchUrl(Uri.parse('nmap://'))) {
        await launchUrl(target.appUri!, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(target.webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('외부 리뷰 페이지를 열 수 없습니다.');
    }
  }

  Future<void> _openGoogleReview(StoreDetail data) async {
    final uri = _storeReviewService.getGoogleMapSearchUri(
      data.googleSearchQuery,
    );

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('외부 리뷰 페이지를 열 수 없습니다.');
    }
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
