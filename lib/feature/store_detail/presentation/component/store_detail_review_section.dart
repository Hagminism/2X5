import 'package:capstone_2026/core/utils/deep_link_util.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class StoreDetailReviewSection extends StatelessWidget {
  final String naverPlaceId; // 네이버 플레이스 ID
  final String googleSearchQuery; // 구글 지도 검색어
  final AiReviewSummary? aiSummary; // AI 요약 데이터
  final List<ReviewItem>? reviews; // 자체 리뷰 리스트

  const StoreDetailReviewSection({
    super.key,
    required this.naverPlaceId,
    required this.googleSearchQuery,
    this.aiSummary,
    this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    // 임시 데이터 (나중에 실제 데이터로 교체될 예정)
    final summary = aiSummary ?? const AiReviewSummary(
      oneLine: '조용한 분위기에서 즐기는 고퀄리티 파스타, 기념일에 방문하기 좋아요',
      keywords: ['분위기 맛집', '친절한 서비스', '재방문 의사 높음'],
      positiveRatio: 0.92,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. AI 지능형 요약 섹션
        _AiSummaryBox(summary: summary),
        const SizedBox(height: 32),

        // 2. 외부 리뷰 확인 섹션
        const Text(
          '외부 리뷰 확인',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ExternalReviewButton(
                title: '네이버 지도',
                logoPath: 'assets/icons/naver.png',
                onTap: () => DeepLinkUtil.launchNaverMapReview(naverPlaceId),
                backgroundColor: const Color(0xFF03C75A),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ExternalReviewButton(
                title: '구글 지도',
                logoPath: 'assets/icons/google.png',
                onTap: () => DeepLinkUtil.launchGoogleMapSearch(googleSearchQuery),
                backgroundColor: Colors.white,
                textColor: AppColors.textPrimary,
                showBorder: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // 3. 자체 리뷰 헤더 및 작성 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '방문자 리뷰',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: 리뷰 작성 페이지 연결
              },
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('리뷰 쓰기'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 4. 자체 리뷰 리스트 (성능 개선: Column + map 방식)
        if (reviews == null || reviews!.isEmpty)
          const Column(
            children: [
              _InternalReviewItem(),
              Divider(height: 32, color: AppColors.border, thickness: 1),
              _InternalReviewItem(),
              Divider(height: 32, color: AppColors.border, thickness: 1),
              _InternalReviewItem(),
            ],
          )
        else
          ...reviews!.asMap().entries.map((entry) {
            final isLast = entry.key == reviews!.length - 1;
            return Column(
              children: [
                const _InternalReviewItem(),
                if (!isLast) const Divider(height: 32, color: AppColors.border, thickness: 1),
              ],
            );
          }),
      ],
    );
  }
}

// --- 데이터 모델 클래스 ---
class AiReviewSummary {
  final String oneLine;
  final List<String> keywords;
  final double positiveRatio;

  const AiReviewSummary({
    required this.oneLine,
    required this.keywords,
    required this.positiveRatio,
  });
}

class ReviewItem {
  // 실제 데이터 필드 정의 예정
}

// --- 내부 컴포넌트 ---
class _AiSummaryBox extends StatelessWidget {
  final AiReviewSummary summary;
  const _AiSummaryBox({required this.summary});

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
              Text('AI 리뷰 요약', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text('"${summary.oneLine}"', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.5, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: summary.keywords.map((kw) => _AiKeywordTag(label: kw)).toList(),
          ),
          const SizedBox(height: 16),
          _AiSentimentBar(positiveRatio: summary.positiveRatio),
        ],
      ),
    );
  }
}

class _AiKeywordTag extends StatelessWidget {
  final String label;
  const _AiKeywordTag({required this.label});

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
  final double positiveRatio;
  const _AiSentimentBar({required this.positiveRatio});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('긍정 후기', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text('${(positiveRatio * 100).toInt()}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
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
  final String title;
  final String logoPath;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final bool showBorder;

  const _ExternalReviewButton({
    required this.title,
    required this.logoPath,
    required this.onTap,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.showBorder = false,
  });

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
            Image.asset(logoPath, width: 20, height: 20, errorBuilder: (_, __, ___) => const Icon(Icons.link, size: 20)),
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

class _InternalReviewItem extends StatelessWidget {
  const _InternalReviewItem();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                  const Text(
                    '예약자 닉네임',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star_rounded,
                        color: index < 4 ? Colors.amber : AppColors.border,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '2024.04.19',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          '매장 분위기가 너무 좋고 파스타가 정말 맛있었습니다! 다음에도 꼭 다시 방문하고 싶네요. 직원분들도 친절하셔서 기분 좋게 식사했습니다.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.image_outlined, color: Colors.white),
        ),
      ],
    );
  }
}
