import 'package:capstone_2026/feature/my_page/review_history/presentation/screen/review_history_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class ReviewHistoryScreen extends StatelessWidget {
  const ReviewHistoryScreen({
    required this.state,
    super.key,
  });

  final ReviewHistoryState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('리뷰 내역'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.reviews.isEmpty
            ? const Center(
                child: Text(
                  '작성한 리뷰가 아직 없습니다.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.reviews.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final review = state.reviews[index];
                  final storeTitle = review.storeName.isEmpty
                      ? review.storeId
                      : review.storeName;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(
                          5,
                          (starIndex) => Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: starIndex < review.rating.round()
                                ? Colors.amber
                                : AppColors.border,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review.content.isEmpty
                            ? '리뷰 내용이 없습니다.'
                            : review.content,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatReviewDate(review.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

String _formatReviewDate(DateTime date) {
  if (date.millisecondsSinceEpoch == 0) {
    return '';
  }

  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year.$month.$day';
}
