import 'dart:io';

import 'package:capstone_2026/core/presentation/component/full_screen_image_viewer.dart';
import 'package:capstone_2026/core/utils/date_format_util.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/google_place_review_info.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/review_ai_summary.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:capstone_2026/feature/stamp/domain/model/store_stamp_status.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:capstone_2026/feature/information/presentation/component/tabs/store_review_tab.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';
import 'package:capstone_2026/core/presentation/util/review_submit_loading.dart';

const bool _allowReviewStampTestingBypass = bool.fromEnvironment(
  'ALLOW_REVIEW_STAMP_TEST_BYPASS',
  defaultValue: !kReleaseMode,
);

class StoreDetailReviewSection extends StatelessWidget {
  const StoreDetailReviewSection({
    required this.storeName,
    required this.location,
    this.naverPlaceId,
    required this.googleSearchQuery,
    this.stampStatus,
    required this.onTapNaverReview,
    required this.onTapGoogleReview,
    required this.onSubmitReview,
    this.isReviewLoading = false,
    required this.naverReviews,
    required this.isNaverDataLoading,
    required this.selectedPlatform,
    required this.onPlatformChanged,
    this.googleReviews = const [],
    this.aiSummary,
    this.isSummaryLoading = false,
    this.summaryError,
    this.onRetrySummary,
    this.reviews,
    super.key,
  });

  final String storeName;
  final String location;
  final String? naverPlaceId;
  final String googleSearchQuery;
  final StoreStampStatus? stampStatus;
  final VoidCallback onTapNaverReview;
  final VoidCallback onTapGoogleReview;
  final Future<void> Function(ReviewWriteResult result) onSubmitReview;
  final bool isReviewLoading;
  final List<Map<String, dynamic>> naverReviews;
  final bool isNaverDataLoading;
  final ReviewPlatform selectedPlatform;
  final void Function(ReviewPlatform) onPlatformChanged;
  final List<GooglePlaceReview> googleReviews;
  final ReviewAiSummary? aiSummary;
  final bool isSummaryLoading;
  final String? summaryError;
  final VoidCallback? onRetrySummary;
  final List<InternalReview>? reviews;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReviewSummaryBox(
          storeName: storeName,
          summary: aiSummary,
          isLoading: isSummaryLoading,
          errorMessage: summaryError,
          onRetry: onRetrySummary,
        ),
        const SizedBox(height: 40),
        const Text(
          '외부 리뷰 페이지로 이동',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ExternalReviewButton(
                title: '네이버 지도',
                logoPath: 'assets/icons/naver.png',
                onTap: onTapNaverReview,
                backgroundColor: const Color(0xFF03C75A),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ExternalReviewButton(
                title: '구글 지도',
                logoPath: 'assets/icons/google.png',
                onTap: onTapGoogleReview,
                backgroundColor: Colors.white,
                textColor: AppColors.textPrimary,
                showBorder: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        const Text(
          '플랫폼별 리뷰 간편 확인',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
        ),
        // TODO: 특정 매장을 이용한 "이력"을 기반으로 리뷰를 작성하는데, 굳이 여기에 작성 버튼이 있어야할 이유가 있을까?
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //     const Text(
        //       '플랫폼별 리뷰 간편 확인',
        //       style: TextStyle(
        //         fontFamily: 'Pretendard',
        //         fontSize: 16,
        //         fontWeight: FontWeight.w600,
        //         letterSpacing: -0.3,
        //         color: AppColors.textPrimary,
        //       ),
        //     ),
        //     if (selectedPlatform == ReviewPlatform.internal)
        //       Material(
        //         color: Colors.transparent,
        //         child: InkWell(
        //           borderRadius: BorderRadius.circular(8),
        //           onTap: () => _showWriteReviewBottomSheet(context),
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             crossAxisAlignment: CrossAxisAlignment.center,
        //             children: [
        //               const Icon(
        //                 Icons.edit_outlined,
        //                 size: 14,
        //                 color: AppColors.primary,
        //               ),
        //               const SizedBox(width: 4),
        //               const Text(
        //                 '리뷰 쓰기',
        //                 style: TextStyle(
        //                   fontFamily: 'Pretendard',
        //                   fontSize: 14,
        //                   fontWeight: FontWeight.w500,
        //                   letterSpacing: -0.3,
        //                   color: AppColors.primary,
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //   ],
        // ),
        const SizedBox(height: 12),
        _ReviewPlatformSegmentedButton(
          selectedPlatform: selectedPlatform,
          onChanged: onPlatformChanged,
        ),
        const SizedBox(height: 24),
        if (selectedPlatform == ReviewPlatform.internal) ...[
          if (isReviewLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (reviews == null || reviews!.isEmpty)
            _EmptyReviewState(
              onTapWriteReview: () => _showWriteReviewBottomSheet(context),
            )
          else
            ...reviews!.asMap().entries.map((entry) {
              final isLast = entry.key == reviews!.length - 1;
              return Column(
                children: [
                  _InternalReviewItem(review: entry.value),
                  if (!isLast)
                    const Divider(
                      height: 32,
                      color: AppColors.border,
                      thickness: 1,
                    ),
                ],
              );
            }),
        ] else if (selectedPlatform == ReviewPlatform.naver) ...[
          if (isNaverDataLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF03C75A)),
                ),
              ),
            )
          else if (naverReviews.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  '아직 등록된 네이버 플레이스 리뷰가 없습니다.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: naverReviews.length,
              separatorBuilder: (context, index) => const Divider(
                height: 32,
                color: AppColors.border,
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final review = naverReviews[index];
                return _NaverReviewItem(review: review);
              },
            ),
        ] else ...[
          const _GoogleInfoBanner(),
          const SizedBox(height: 24),
          if (googleReviews.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  '아직 등록된 Google 지도 리뷰가 없습니다.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: googleReviews.length,
              separatorBuilder: (context, index) => const Divider(
                height: 32,
                color: AppColors.border,
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final review = googleReviews[index];
                return _GoogleReviewItem(review: review);
              },
            ),
        ],
      ],
    );
  }

  Future<void> _showWriteReviewBottomSheet(BuildContext context) async {
    if (!_allowReviewStampTestingBypass &&
        stampStatus != null &&
        !stampStatus!.canWriteReview) {
      AppSnackBar.showError(context, stampStatus!.reviewEligibilityMessage);
      return;
    }

    final result = await showModalBottomSheet<ReviewWriteResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ReviewWriteBottomSheet(storeName: storeName),
    );

    if (result == null || !context.mounted) {
      return;
    }

    await runWithReviewSubmitLoading(
      context,
      () => onSubmitReview(result),
    );
  }
}

class _ReviewSummaryBox extends StatelessWidget {
  const _ReviewSummaryBox({
    required this.storeName,
    required this.summary,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final String storeName;
  final ReviewAiSummary? summary;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'AI 리뷰 요약',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (errorMessage != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    errorMessage!,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: onRetry,
                        child: const Text('다시 시도'),
                      ),
                    ),
                  ],
                ],
              )
            else
              _SummaryContent(
                summary: summary ?? ReviewAiSummary.empty(storeName: storeName),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({required this.summary});

  final ReviewAiSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '"${summary.oneLine}"',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.5,
            letterSpacing: -0.1,
            color: AppColors.textPrimary,
          ),
        ),
        if (summary.reviewCounts != null && summary.reviewCounts!.total > 0) ...[
          const SizedBox(height: 8),
          Text(
            summary.reviewCounts!.toCaption(),
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: summary.keywords
              .map((keyword) => _AiKeywordTag(label: keyword))
              .toList(),
        ),
        if (summary.hasPositiveRatio) ...[
          const SizedBox(height: 16),
          _AiSentimentBar(positiveRatio: summary.positiveRatio),
        ],
      ],
    );
  }
}

class _AiKeywordTag extends StatelessWidget {
  const _AiKeywordTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        '# $label',
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _AiSentimentBar extends StatelessWidget {
  const _AiSentimentBar({required this.positiveRatio});

  final double positiveRatio;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '긍정 비율',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${(positiveRatio * 100).toInt()}%',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: positiveRatio,
            minHeight: 6,
            backgroundColor: AppColors.border,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _ExternalReviewButton extends StatelessWidget {
  const _ExternalReviewButton({
    required this.title,
    required this.logoPath,
    required this.onTap,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.showBorder = false,
  });

  final String title;
  final String logoPath;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: showBorder ? Border.all(color: AppColors.border) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              logoPath,
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.link, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyReviewState extends StatelessWidget {
  const _EmptyReviewState({required this.onTapWriteReview});

  final VoidCallback onTapWriteReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: const Text(
          '아직 등록된 자체 리뷰가 없습니다.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _InternalReviewItem extends StatelessWidget {
  const _InternalReviewItem({required this.review});

  final InternalReview review;

  @override
  Widget build(BuildContext context) {
    final displayName = review.userName.isEmpty ? '방문자' : review.userName;
    final reviewText = review.content.isEmpty
        ? '등록된 리뷰 내용이 없습니다.'
        : review.content;
    final visitPurpose = review.visitPurpose?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.border,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star_rounded,
                        color: index < review.rating.round()
                            ? Colors.amber
                            : AppColors.border,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatDotDate(review.createdAt),
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        if (review.imageUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: review.imageUrls.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FullScreenImageViewer(
                          imageUrls: review.imageUrls,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _ReviewImageThumbnail(
                      imagePath: review.imageUrls[index],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        if (visitPurpose != null && visitPurpose.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '[$visitPurpose]으로 방문함',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          reviewText,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            height: 1.5,
            letterSpacing: -0.1,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ReviewImageThumbnail extends StatelessWidget {
  const _ReviewImageThumbnail({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    if (_isFilePath(imagePath)) {
      return Image.file(
        File(imagePath),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    return Image.asset(
      imagePath,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  bool _isFilePath(String value) {
    return value.startsWith('/') || RegExp(r'^[A-Za-z]:\\').hasMatch(value);
  }

  Widget _buildFallback() {
    return Container(
      width: 80,
      height: 80,
      color: AppColors.border,
      child: const Icon(
        Icons.broken_image_outlined,
        color: Colors.white,
      ),
    );
  }
}

class _NaverReviewItem extends StatelessWidget {
  const _NaverReviewItem({required this.review});

  final Map<String, dynamic> review;

  @override
  Widget build(BuildContext context) {
    final author = review['author'] as Map<String, dynamic>?;
    final nickname = author?['nickname'] as String? ?? '익명';
    final imageUrl = author?['imageUrl'] as String? ?? '';
    final date = review['created'] as String? ?? '';
    final bodyText = review['body'] as String? ?? '';
    final mediaList = review['media'] as List<dynamic>? ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFF3F4F6),
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : null,
              child: imageUrl.isEmpty
                  ? const Icon(Icons.person, color: Color(0xFF9CA3AF), size: 20)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nickname,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (date.isNotEmpty)
              Text(
                date,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          bodyText.isEmpty ? '리뷰 내용이 없습니다.' : bodyText,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            height: 1.5,
            letterSpacing: -0.1,
            color: AppColors.textPrimary,
          ),
        ),
        if (mediaList.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mediaList.length,
              itemBuilder: (context, index) {
                final media = mediaList[index] as Map<String, dynamic>?;
                final thumbnailUrl = media?['thumbnail'] as String? ?? '';
                if (thumbnailUrl.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      final allImages = mediaList
                          .map(
                            (m) =>
                                (m as Map<String, dynamic>?)?['thumbnail']
                                    as String? ??
                                '',
                          )
                          .where((url) => url.isNotEmpty)
                          .toList();
                      final targetIndex = allImages.indexOf(thumbnailUrl);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FullScreenImageViewer(
                            imageUrls: allImages,
                            initialIndex: targetIndex >= 0 ? targetIndex : 0,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        thumbnailUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100,
                          height: 100,
                          color: const Color(0xFFF3F4F6),
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ReviewPlatformSegmentedButton extends StatelessWidget {
  const _ReviewPlatformSegmentedButton({
    required this.selectedPlatform,
    required this.onChanged,
  });

  final ReviewPlatform selectedPlatform;
  final void Function(ReviewPlatform) onChanged;

  static const List<(ReviewPlatform, String)> _options = [
    (ReviewPlatform.internal, '자체 리뷰'),
    (ReviewPlatform.naver, '네이버 플레이스'),
    (ReviewPlatform.google, 'Google 지도'),
  ];

  static Alignment _alignmentFor(ReviewPlatform platform) {
    return switch (platform) {
      ReviewPlatform.internal => Alignment.centerLeft,
      ReviewPlatform.naver => Alignment.center,
      ReviewPlatform.google => Alignment.centerRight,
    };
  }

  static LinearGradient _gradientFor(ReviewPlatform platform) {
    return switch (platform) {
      ReviewPlatform.internal => const LinearGradient(
        colors: [AppColors.primary, Color(0xFFE63500)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ReviewPlatform.naver => const LinearGradient(
        colors: [Color(0xFF03C75A), Color(0xFF02A34A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ReviewPlatform.google => const LinearGradient(
        colors: [Color(0xFF4285F4), Color(0xFF357AE8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    };
  }

  static Color _shadowColorFor(ReviewPlatform platform) {
    return switch (platform) {
      ReviewPlatform.internal => AppColors.primary,
      ReviewPlatform.naver => const Color(0xFF03C75A),
      ReviewPlatform.google => const Color(0xFF4285F4),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth / _options.length;
          return Stack(
            children: [
              AnimatedAlign(
                alignment: _alignmentFor(selectedPlatform),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Container(
                  width: width,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: _gradientFor(selectedPlatform),
                    boxShadow: [
                      BoxShadow(
                        color: _shadowColorFor(
                          selectedPlatform,
                        ).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (final (platform, label) in _options)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(platform),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              fontWeight: selectedPlatform == platform
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selectedPlatform == platform
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                            ),
                            child: Text(label),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GoogleInfoBanner extends StatelessWidget {
  const _GoogleInfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '구글 공식 API 제한으로 인해 최신 리뷰 5개만 표시됩니다.',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E40AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleReviewItem extends StatelessWidget {
  const _GoogleReviewItem({required this.review});

  final GooglePlaceReview review;

  @override
  Widget build(BuildContext context) {
    final authorName = review.authorName?.trim().isNotEmpty == true
        ? review.authorName!
        : 'Google 사용자';
    final rating = review.rating ?? 0.0;
    final text = review.text.trim().isNotEmpty == true
        ? review.text
        : '리뷰 내용이 없습니다.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFF3F4F6),
              child: Icon(Icons.person, color: Color(0xFF9CA3AF), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authorName,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star_rounded,
                        color: index < rating.round()
                            ? Colors.amber
                            : AppColors.border,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            height: 1.5,
            letterSpacing: -0.1,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
