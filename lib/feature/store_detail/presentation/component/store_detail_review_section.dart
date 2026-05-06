import 'dart:io';

import 'package:capstone_2026/core/utils/date_format_util.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/review_ai_summary.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class StoreDetailReviewSection extends StatelessWidget {
  const StoreDetailReviewSection({
    required this.storeName,
    required this.location,
    this.naverPlaceId,
    required this.googleSearchQuery,
    required this.onTapNaverReview,
    required this.onTapGoogleReview,
    required this.onSubmitReview,
    this.isReviewLoading = false,
    this.aiSummary,
    this.reviews,
    super.key,
  });

  final String storeName;
  final String location;
  final String? naverPlaceId;
  final String googleSearchQuery;
  final VoidCallback onTapNaverReview;
  final VoidCallback onTapGoogleReview;
  final Future<void> Function(ReviewWriteResult result) onSubmitReview;
  final bool isReviewLoading;
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
      ],
    );
  }

  Future<void> _showWriteReviewBottomSheet(BuildContext context) async {
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
