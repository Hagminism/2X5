import 'package:capstone_2026/core/presentation/util/app_date_picker.dart';
import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/domain/util/store_image_display.dart';
import 'package:capstone_2026/feature/information/presentation/component/information_image_slider.dart';
import 'package:capstone_2026/feature/information/presentation/component/information_sticky_tab_bar_delegate.dart';
import 'package:capstone_2026/feature/information/presentation/component/information_store_header.dart';
import 'package:capstone_2026/feature/information/presentation/screen/tabs/store_home_tab.dart';
import 'package:capstone_2026/feature/information/presentation/screen/tabs/store_layout_tab.dart';
import 'package:capstone_2026/feature/information/presentation/screen/tabs/store_menu_tab.dart';
import 'package:capstone_2026/feature/information/presentation/screen/tabs/store_photo_tab.dart';
import 'package:capstone_2026/feature/information/presentation/component/tabs/store_reservation_tab.dart';
import 'package:capstone_2026/feature/information/presentation/component/tabs/store_review_tab.dart';
import 'package:capstone_2026/feature/search_store_information/store_information/presentation/screen/search_store_information_action.dart';
import 'package:capstone_2026/feature/search_store_information/store_information/presentation/screen/search_store_information_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchStoreInformationScreen extends StatelessWidget {
  final SearchStoreInformationState state;
  final void Function(SearchStoreInformationAction action) onAction;

  const SearchStoreInformationScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (state.tabs.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Stack(
      children: [
        DefaultTabController(
          length: state.tabs.length,
          child: Scaffold(
            backgroundColor: AppColors.white,
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
                  onAction(const SearchStoreInformationAction.tapBack());
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () {
                    onAction(const SearchStoreInformationAction.tapShare());
                  },
                ),
                IconButton(
                  icon: Icon(
                    state.isBookmarked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () {
                    onAction(const SearchStoreInformationAction.tapBookmark());
                  },
                ),
              ],
            ),
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: InformationImageSlider(
                      controller: state.sliderController ?? PageController(),
                      currentPage: state.currentSliderPage,
                      onPageChanged: (int index) {
                        onAction(
                          SearchStoreInformationAction.sliderPageChanged(index),
                        );
                      },
                      images: storeSliderImages(state.imageUrls),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: InformationStoreHeader(
                      name: state.name,
                      subtitle: state.subtitle,
                      rating: state.rating,
                      imageUrl: state.imageUrl,
                      showRating: state.isReservationAvailable,
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: InformationStickyTabBarDelegate(
                      TabBar(
                        isScrollable: false,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.primary,
                        indicatorWeight: 3,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        tabs: state.tabs
                            .map((title) => Tab(text: title))
                            .toList(),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  Builder(
                    builder: (innerContext) {
                      return StoreHomeTab(
                        address: state.address,
                        displayPhone: state.displayPhone,
                        description: state.storeDescription,
                        operatingHours: state.operatingHours,
                        menus: state.menus,
                        onViewMoreMenus: () {
                          final controller = DefaultTabController.of(
                            innerContext,
                          );
                          final category = StoreCategory.fromDbValue(
                            state.category,
                          );
                          final isCafeOrRestaurant =
                              category == StoreCategory.cafe ||
                              category == StoreCategory.restaurant;
                          if (isCafeOrRestaurant) {
                            controller.animateTo(1);
                          }
                        },
                        showMenuSection:
                            StoreCategory.fromDbValue(state.category) ==
                                StoreCategory.cafe ||
                            StoreCategory.fromDbValue(state.category) ==
                                StoreCategory.restaurant,
                      );
                    },
                  ),
                  if (StoreCategory.fromDbValue(state.category) ==
                          StoreCategory.cafe ||
                      StoreCategory.fromDbValue(state.category) ==
                          StoreCategory.restaurant)
                    StoreMenuTab(menus: state.menus),
                  if (StoreCategory.fromDbValue(state.category) ==
                          StoreCategory.cafe ||
                      StoreCategory.fromDbValue(state.category) ==
                          StoreCategory.restaurant)
                    StoreLayoutTab(
                      layoutDetail: state.layoutDetail,
                      isReservationAvailable: state.isReservationAvailable,
                    ),
                  StoreReservationStatusTab(
                    category: state.category,
                    isReservationAvailable: state.isReservationAvailable,
                    salonDesigners: state.salonDesigners,
                    operatingHours: state.operatingHours,
                    reservationAvailabilityDate:
                        state.reservationAvailabilityDate,
                    reservationAvailabilitySlots:
                        state.reservationAvailabilitySlots,
                    isReservationAvailabilityLoading:
                        state.isReservationAvailabilityLoading,
                    onSelectReservationDate: (date) {
                      onAction(
                        SearchStoreInformationAction.changeReservationAvailabilityDate(
                          date,
                        ),
                      );
                    },
                    onPickReservationDate: () async {
                      final picked = await AppDatePicker.show(
                        context,
                        initialDate:
                            state.reservationAvailabilityDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) {
                        onAction(
                          SearchStoreInformationAction.changeReservationAvailabilityDate(
                            picked,
                          ),
                        );
                      }
                    },
                    onTapReservation: () {
                      final currentLocation = GoRouterState.of(
                        context,
                      ).matchedLocation;
                      onAction(
                        SearchStoreInformationAction.tapReservation(
                          currentLocation,
                        ),
                      );
                    },
                    onTapSalonDesigner:
                        StoreCategory.fromDbValue(state.category) ==
                            StoreCategory.salon
                        ? (String designerId) {
                            final currentLocation = GoRouterState.of(
                              context,
                            ).matchedLocation;
                            onAction(
                              SearchStoreInformationAction.tapSalonDesignerReservation(
                                currentLocation: currentLocation,
                                designerId: designerId,
                              ),
                            );
                          }
                        : null,
                  ),
                  StorePhotoTab(imageUrls: state.imageUrls),
                  StoreReviewTab(
                    storeId: state.storeId,
                    storeName: state.name,
                    location: state.address,
                    naverPlaceId: state.naverPlaceId,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (state.isLoading)
          ModalBarrier(
            dismissible: false,
            color: AppColors.black.withValues(alpha: 0.2588),
          ),
        if (state.isLoading)
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }
}
