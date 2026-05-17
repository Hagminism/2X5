import 'package:flutter/material.dart';
import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'tabs/store_home_tab.dart';
import 'tabs/store_menu_tab.dart';
import 'tabs/store_photo_tab.dart';
import 'tabs/store_review_tab.dart';
import 'tabs/store_reservation_tab.dart';

class InformationScreen extends StatefulWidget {
  final String storeId;
  final String name;
  final String subtitle;
  final String address;
  /// `phone` 우선·없으면 `contact` (뷰모델 `displayPhone`).
  final String displayPhone;
  final double rating;
  final List<String> imageUrls;
  final List<StoreMenu> menus;

  const InformationScreen({
    required this.storeId,
    required this.name,
    required this.subtitle,
    this.address = '',
    this.displayPhone = '',
    required this.rating,
    this.imageUrls = const [],
    this.menus = const [],
    super.key,
  });

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _sliderController = PageController();
  int _currentSliderPage = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sliderController.dispose();
    super.dispose();
  }

  List<String> _sliderUrlsForTop() {
    final taken = widget.imageUrls.take(10).toList();
    if (taken.isEmpty) {
      return const [''];
    }
    return taken;
  }

  String? _headerThumbnailUrl() {
    if (widget.imageUrls.isEmpty) return null;
    final u = widget.imageUrls.first.trim();
    return u.isEmpty ? null : u;
  }

  @override
  Widget build(BuildContext context) {
    final sliderUrls = _sliderUrlsForTop();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.favorite_border_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _sliderController,
                      onPageChanged: (index) =>
                          setState(() => _currentSliderPage = index),
                      itemCount: sliderUrls.length,
                      itemBuilder: (context, index) {
                        final url = sliderUrls[index].trim();
                        final hasUrl = url.isNotEmpty;
                        return Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceMuted,
                          ),
                          child: hasUrl
                              ? Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.storefront_rounded,
                                      size: 64,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.storefront_rounded,
                                    size: 64,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          sliderUrls.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentSliderPage == index
                                  ? AppColors.primary
                                  : AppColors.textSecondary.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildStoreHeader()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  tabs: const [
                    Tab(text: '홈'),
                    Tab(text: '메뉴'),
                    Tab(text: '사진'),
                    Tab(text: '리뷰'),
                    Tab(text: '정보'),
                    Tab(text: '예약'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            StoreHomeTab(
              address: widget.address,
              displayPhone: widget.displayPhone,
              menus: widget.menus,
              onViewMoreMenus: () => _tabController.animateTo(1),
            ),
            StoreMenuTab(menus: widget.menus),
            StorePhotoTab(imageUrls: widget.imageUrls),
            StoreReviewTab(storeId: widget.storeId),
            const Center(child: Text('정보 탭')),
            const StoreReservationStatusTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreHeader() {
    final thumb = _headerThumbnailUrl();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              image: thumb != null
                  ? DecorationImage(
                      image: NetworkImage(thumb),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: thumb == null
                ? const Icon(
                    Icons.storefront_rounded,
                    size: 32,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}