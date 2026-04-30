import 'package:flutter/material.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';

class StoreReviewTab extends StatelessWidget {
  const StoreReviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    // 실제 데이터가 들어오기 전까지 임시
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      separatorBuilder: (context, index) => const Divider(
        height: 40,
        color: AppColors.border,
        thickness: 1,
      ),
      itemBuilder: (context, index) {
        return _buildReviewItem();
      },
    );
  }


  Widget _buildReviewItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 프로필 이미지 영역 (BoxCircle -> BoxShape.circle로 수정)
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle, // 여기서 에러가 났을 거예요!
              ),
              child: const Icon(Icons.person, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            // 이름과 평점
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '리뷰 작성자',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                      Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                      Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                      Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                      Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                      SizedBox(width: 4),
                      Text('5.0', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const Text('2026.04.30', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 12),
        // 리뷰 본문
        const Text(
          '매장이 깔끔하고 사장님이 친절하세요! 다음에 또 방문하고 싶습니다. 추천합니다!',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}