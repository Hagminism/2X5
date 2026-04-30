import 'package:flutter/material.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';

// 🛠️ 수정: 탭 파일 임포트 경로 확인 (프로젝트 구조에 맞게 조정됨)
import 'tabs/store_review_tab.dart';
import 'tabs/store_reservation_tab.dart';

class StoreDetailScreen extends StatefulWidget {
  final String name;
  final String subtitle;
  final double rating;

  const StoreDetailScreen({
    required this.name,
    required this.subtitle,
    required this.rating,
    super.key,
  });

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () {
            // 🛠️ 수정: GoRouter(context.pop) 대신 기존 Navigator 방식으로 복구
            Navigator.of(context).pop();
          },
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
            SliverToBoxAdapter(
              child: _buildStoreHeader(),
            ),
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
            StoreReservationStatusTab(), // 🛠️ 여기서 아까 수정한 Navigator 방식 버튼이 들어감
          ],
        ),
      ),
    );
  }

  Widget _buildStoreHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.storefront_rounded, size: 32, color: AppColors.textSecondary),
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
        color: Colors.white, // AppColors.surface 대신 직관적인 화이트 배경
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}