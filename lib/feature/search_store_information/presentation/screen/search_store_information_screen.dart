import 'package:capstone_2026/feature/information/presentation/component/information_image_slider.dart';
import 'package:capstone_2026/feature/information/presentation/component/information_sticky_tab_bar_delegate.dart';
import 'package:capstone_2026/feature/information/presentation/component/information_store_header.dart';
import 'package:capstone_2026/feature/information/presentation/component/tabs/store_home_tab.dart';
import 'package:capstone_2026/feature/information/presentation/component/tabs/store_info_tab.dart';
import 'package:capstone_2026/feature/information/presentation/component/tabs/store_menu_tab.dart';
import 'package:capstone_2026/feature/information/presentation/component/tabs/store_photo_tab.dart';
import 'package:capstone_2026/feature/information/presentation/component/tabs/store_reservation_tab.dart';
import 'package:capstone_2026/feature/information/presentation/component/tabs/store_review_tab.dart';
import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_store_information_action.dart';
import 'package:capstone_2026/feature/search_store_information/presentation/screen/search_store_information_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchStoreInformationScreen extends StatefulWidget {
  final SearchStoreInformationState state;
  final void Function(SearchStoreInformationAction action) onAction;

  const SearchStoreInformationScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  State<SearchStoreInformationScreen> createState() =>
      _SearchStoreInformationScreenState();
}

class _SearchStoreInformationScreenState extends State<SearchStoreInformationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 6,
    vsync: this,
  );
  final PageController _sliderController = PageController();
  int _currentSliderPage = 0;

  @override
  Widget build(BuildContext context) {
    final List<String?> sliderImages = [widget.state.imageUrl, null, null];

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: AppColors.white,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            widget.onAction(const SearchStoreInformationAction.tapBack());
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              widget.onAction(const SearchStoreInformationAction.tapShare());
            },
          ),
          IconButton(
            icon: Icon(
              widget.state.isBookmarked
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              widget.onAction(const SearchStoreInformationAction.tapBookmark());
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: InformationImageSlider(
                controller: _sliderController,
                currentPage: _currentSliderPage,
                onPageChanged: (int index) {
                  setState(() {
                    _currentSliderPage = index;
                  });
                },
                images: sliderImages,
              ),
            ),
            SliverToBoxAdapter(
              child: InformationStoreHeader(
                name: widget.state.name,
                subtitle: widget.state.subtitle,
                rating: widget.state.rating,
                imageUrl: widget.state.imageUrl,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: InformationStickyTabBarDelegate(
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
            const StoreHomeTab(),
            const StoreMenuTab(),
            const StorePhotoTab(),
            const StoreReviewTab(),
            const StoreInfoTab(),
            StoreReservationStatusTab(
              category: widget.state.category,
              onTapReservation: () {
                final currentLocation = GoRouterState.of(
                  context,
                ).matchedLocation;
                widget.onAction(
                  SearchStoreInformationAction.tapReservation(currentLocation),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sliderController.dispose();
    super.dispose();
  }
}
