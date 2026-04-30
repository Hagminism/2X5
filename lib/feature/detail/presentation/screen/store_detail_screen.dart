import 'package:flutter/material.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';

// 탭 파일 임포트 경로 확인
import 'tabs/store_review_tab.dart';
import 'tabs/store_reservation_tab.dart';

class StoreDetailScreen extends StatefulWidget {
  final String name;
  final String subtitle;
  final double rating;
  final String? imageUrl;

  const StoreDetailScreen({
    required this.name,
    required this.subtitle,
    required this.rating,
    this.imageUrl,
    super.key,
  });

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen>
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

  @override
  Widget build(BuildContext context) {
    // 🚀 이상한 이미지 대신 상점 아이콘이 포함된 빈 슬라이더 구성
    final List<String?> sliderImages = [
      widget.imageUrl, // 실제 이미지가 있으면 첫 장에 표시
      null, // 빈 화면(아이콘)
      null, // 빈 화면(아이콘)
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(), //
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // 1. 🚀 상단 슬라이더 영역 (빈 화면 또는 아이콘 배치)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _sliderController,
                      onPageChanged: (index) => setState(() => _currentSliderPage = index),
                      itemCount: sliderImages.length,
                      itemBuilder: (context, index) {
                        final String? url = sliderImages[index];
                        return Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(color: AppColors.surfaceMuted), //
                          child: url != null
                              ? Image.network(url, fit: BoxFit.cover)
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
                    // 슬라이더 인디케이터
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          sliderImages.length,
                              (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentSliderPage == index
                                  ? AppColors.primary
                                  : AppColors.textSecondary.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 2. 🚀 기존 가게 정보 헤더 (아이콘 유지)
            SliverToBoxAdapter(
              child: _buildStoreHeader(),
            ),
            // 3. 🚀 탭바 영역
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
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
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
          children: const [
            Center(child: Text('홈 탭')),
            Center(child: Text('메뉴 탭')),
            Center(child: Text('사진 탭')),
            StoreReviewTab(),
            Center(child: Text('정보 탭')),
            StoreReservationStatusTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          // 🛠️ 기존 아이콘 박스 레이아웃 그대로 유지
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              image: widget.imageUrl != null
                  ? DecorationImage(
                image: NetworkImage(widget.imageUrl!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: widget.imageUrl == null
                ? const Icon(Icons.storefront_rounded, size: 32, color: AppColors.textSecondary)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(widget.subtitle, style: AppTextStyles.subtitle),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      widget.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
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
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}