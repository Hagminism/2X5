import 'dart:io';

import 'package:capstone_2026/core/utils/date_format_util.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/google_place_review_info.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/review_ai_summary.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:capstone_2026/feature/stamp/domain/model/store_stamp_status.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
    this.googlePlaceReviewInfo,
    required this.onTapNaverReview,
    required this.onTapGoogleReview,
    required this.onSubmitReview,
    this.isReviewLoading = false,
    required this.naverReviews,
    required this.isNaverDataLoading,
    this.aiSummary,
    this.reviews,
    super.key,
  });

  final String storeName;
  final String location;
  final String? naverPlaceId;
  final String googleSearchQuery;
  final StoreStampStatus? stampStatus;
  final GooglePlaceReviewInfo? googlePlaceReviewInfo;
  final VoidCallback onTapNaverReview;
  final VoidCallback onTapGoogleReview;
  final Future<void> Function(ReviewWriteResult result) onSubmitReview;
  final bool isReviewLoading;
  final List<Map<String, dynamic>> naverReviews;
  final bool isNaverDataLoading;
  final ReviewAiSummary? aiSummary;
  final List<InternalReview>? reviews;


  @override
  Widget build(BuildContext context) {
    final summary =
        aiSummary ??
        const ReviewAiSummary(
          oneLine: '자체 리뷰가 쌓이면 매장의 강점과 방문 후기를 AI가 간단하게 요약해 보여줄 예정입니다.',
          keywords: ['자체 리뷰', '방문 후기', '스탬프 보상'],
          positiveRatio: 0.92,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AiSummaryBox(summary: summary),
        if (googlePlaceReviewInfo != null &&
            (googlePlaceReviewInfo!.hasSummary ||
                googlePlaceReviewInfo!.rating != null)) ...[
          const SizedBox(height: 16),
          _GoogleReviewSummaryBox(info: googlePlaceReviewInfo!),
        ],
        const SizedBox(height: 32),
        const Text(
          '외부 리뷰 확인',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
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
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '방문자 리뷰',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showWriteReviewBottomSheet(context),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('리뷰 쓰기'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 40),
        const Divider(height: 1, color: AppColors.border, thickness: 1),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF03C75A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'N',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '네이버 플레이스 리뷰',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                '아직 수집된 네이버 실시간 리뷰가 없습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
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
      ],
    );

  }

  Future<void> _showWriteReviewBottomSheet(BuildContext context) async {
    if (!_allowReviewStampTestingBypass &&
        stampStatus != null &&
        !stampStatus!.canWriteReview) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(stampStatus!.reviewEligibilityMessage)),
        );
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

    await onSubmitReview(result);
  }
}

class _AiSummaryBox extends StatelessWidget {
  const _AiSummaryBox({required this.summary});

  final ReviewAiSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'AI 리뷰 요약',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${summary.oneLine}"',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: summary.keywords
                .map((keyword) => _AiKeywordTag(label: keyword))
                .toList(),
          ),
          const SizedBox(height: 16),
          _AiSentimentBar(positiveRatio: summary.positiveRatio),
        ],
      ),
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
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _GoogleReviewSummaryBox extends StatelessWidget {
  const _GoogleReviewSummaryBox({required this.info});

  final GooglePlaceReviewInfo info;

  @override
  Widget build(BuildContext context) {
    final rating = info.rating;
    final userRatingCount = info.userRatingCount;
    final summary = _buildSummaryText(info);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/icons/google.png',
                width: 18,
                height: 18,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.public, size: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                'Google 리뷰 요약',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (rating != null)
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 17,
                      color: Color(0xFFFFB800),
                    ),
                    const SizedBox(width: 2),
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
          if (userRatingCount != null) ...[
            const SizedBox(height: 6),
            Text(
              'Google 리뷰 $userRatingCount개 기준',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (summary != null && summary.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              summary,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _buildSummaryText(GooglePlaceReviewInfo info) {
    final officialSummary = info.reviewSummary?.trim();
    if (officialSummary != null && officialSummary.isNotEmpty) {
      return officialSummary;
    }

    return _GoogleReviewSummaryFallback.build(info.reviews);
  }
}

class _GoogleReviewSummaryFallback {
  const _GoogleReviewSummaryFallback._();

  static const List<_GoogleReviewSummaryPattern> _patterns = [
    _GoogleReviewSummaryPattern(
      label: '친절한 응대',
      keywords: ['친절', '서비스', '직원'],
    ),
    _GoogleReviewSummaryPattern(
      label: '메뉴 만족도',
      keywords: ['맛', '고기', '음식', '커피', '메뉴'],
    ),
    _GoogleReviewSummaryPattern(
      label: '공간 분위기',
      keywords: ['분위기', '넓', '쾌적', '자리'],
    ),
    _GoogleReviewSummaryPattern(
      label: '방문 편의성',
      keywords: ['예약', '대기', '빠르', '바로'],
    ),
    _GoogleReviewSummaryPattern(
      label: '방문 목적 적합성',
      keywords: ['가족', '데이트', '모임', '친구', '회식'],
    ),
  ];

  static String? build(List<GooglePlaceReview> reviews) {
    final combinedText = reviews
        .map((review) => review.text)
        .join(' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (combinedText.isEmpty) {
      return null;
    }

    final matchedLabels = _patterns
        .where((pattern) => pattern.matches(combinedText))
        .map((pattern) => pattern.label)
        .take(2)
        .toList(growable: false);

    if (matchedLabels.isEmpty) {
      return 'Google 리뷰에서 전반적인 이용 경험과 매장 만족도를 확인할 수 있습니다.';
    }

    return 'Google 리뷰에서 ${matchedLabels.join(' · ')} 관련 언급이 확인됩니다.';
  }
}

class _GoogleReviewSummaryPattern {
  const _GoogleReviewSummaryPattern({
    required this.label,
    required this.keywords,
  });

  final String label;
  final List<String> keywords;

  bool matches(String source) {
    return keywords.any(source.contains);
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
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            Text(
              '${(positiveRatio * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
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
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '아직 등록된 자체 리뷰가 없습니다.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '발표 시연에서는 mock 저장소에 리뷰를 쌓아 자연스럽게 흐름을 보여주고, 실제 서비스 단계에서 작성 권한과 저장 로직을 연결할 예정입니다.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onTapWriteReview,
            icon: const Icon(Icons.rate_review_outlined, size: 16),
            label: const Text('리뷰 작성하기'),
          ),
        ],
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _ReviewImageThumbnail(
                    imagePath: review.imageUrls[index],
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
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          reviewText,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
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
              backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
            fontSize: 14,
            height: 1.5,
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
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

