import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/service/review_ai_summary_generator.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/store_detail_review_section.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:capstone_2026/feature/information/presentation/component/tabs/store_review_tab.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/google_place_review_info.dart';

class BookmarkStoreDetailTabSection extends StatefulWidget {
  const BookmarkStoreDetailTabSection({
    required this.selectedTab,
    required this.onTabSelected,
    required this.storeName,
    required this.location,
    this.naverPlaceId,
    required this.googleSearchQuery,
    required this.reviews,
    required this.isReviewLoading,
    required this.isNaverDataLoading,
    required this.naverMenus,
    required this.naverReviews,
    required this.onSubmitReview,
    required this.onTapNaverReview,
    required this.onTapGoogleReview,
    this.googlePlaceReviewInfo,
    super.key,
  });

  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  final String storeName;
  final String location;
  final String? naverPlaceId;
  final String googleSearchQuery;
  final List<InternalReview> reviews;
  final bool isReviewLoading;
  final bool isNaverDataLoading;
  final List<Map<String, dynamic>> naverMenus;
  final List<Map<String, dynamic>> naverReviews;
  final Future<void> Function(ReviewWriteResult result) onSubmitReview;
  final VoidCallback onTapNaverReview;
  final VoidCallback onTapGoogleReview;
  final GooglePlaceReviewInfo? googlePlaceReviewInfo;

  @override
  State<BookmarkStoreDetailTabSection> createState() =>
      _BookmarkStoreDetailTabSectionState();
}

class _BookmarkStoreDetailTabSectionState
    extends State<BookmarkStoreDetailTabSection> {
  ReviewPlatform _selectedPlatform = ReviewPlatform.internal;
  static const List<String> _tabs = ['홈', '메뉴', '사진', '리뷰', '매장정보'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 48,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.border),
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _tabs.length,
            itemBuilder: (_, index) {
              final isSelected = widget.selectedTab == index;
              return InkWell(
                onTap: () => widget.onTabSelected(index),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? AppColors.textPrimary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: _tabView(widget.selectedTab),
        ),
      ],
    );
  }

  Widget _tabView(int tabIndex) {
    switch (tabIndex) {
      case 3:
        return StoreDetailReviewSection(
          storeName: widget.storeName,
          location: widget.location,
          naverPlaceId: widget.naverPlaceId,
          googleSearchQuery: widget.googleSearchQuery,
          aiSummary: ReviewAiSummaryGenerator.generate(
            storeName: widget.storeName,
            reviews: widget.reviews,
          ),
          reviews: widget.reviews,
          isReviewLoading: widget.isReviewLoading,
          naverReviews: widget.naverReviews,
          isNaverDataLoading: widget.isNaverDataLoading,
          selectedPlatform: _selectedPlatform,
          onPlatformChanged: (ReviewPlatform platform) {
            setState(() {
              _selectedPlatform = platform;
            });
          },
          googleReviews: widget.googlePlaceReviewInfo?.reviews ?? const [],
          onSubmitReview: widget.onSubmitReview,
          onTapNaverReview: widget.onTapNaverReview,
          onTapGoogleReview: widget.onTapGoogleReview,
        );
      case 1:
        if (widget.isNaverDataLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF03C75A)),
              ),
            ),
          );
        }
        if (widget.naverMenus.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                '등록된 실시간 메뉴 정보가 없습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.naverMenus.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final menu = widget.naverMenus[index];
            final name = menu['name'] as String? ?? '';
            final priceRaw = menu['price'];
            final description = menu['description'] as String? ?? '';
            final imageUrl = menu['imageUrl'] as String? ?? '';

            // 가격 포맷팅
            String formattedPrice = '';
            if (priceRaw != null) {
              final priceStr = priceRaw.toString().replaceAll(
                RegExp(r'[^0-9]'),
                '',
              );
              final priceInt = int.tryParse(priceStr);
              if (priceInt != null) {
                final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
                formattedPrice =
                    '${priceInt.toString().replaceAllMapped(reg, (match) => ',')}원';
              } else {
                formattedPrice = priceRaw.toString();
              }
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (formattedPrice.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            formattedPrice,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      case 2:
        return const Text(
          '매장 및 메뉴 사진을 갤러리 형태로 보여주는 영역입니다.',
          style: _contentStyle,
        );
      case 4:
        return const Text(
          '주소, 연락처, 운영 시간, 편의 정보가 이 탭에 정리됩니다.',
          style: _contentStyle,
        );
      case 0:
      default:
        return const Text(
          '북마크에서 진입한 상세 페이지에서도 핵심 소개와 리뷰, 외부 링크를 바로 확인할 수 있습니다.',
          style: _contentStyle,
        );
    }
  }

  static const _contentStyle = TextStyle(
    fontSize: 14,
    height: 1.5,
    color: AppColors.textPrimary,
  );
}
