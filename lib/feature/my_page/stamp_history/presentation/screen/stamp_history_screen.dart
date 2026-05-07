import 'package:capstone_2026/feature/my_page/stamp_history/presentation/screen/stamp_history_state.dart';
import 'package:capstone_2026/feature/stamp/domain/model/store_stamp_status.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class StampHistoryScreen extends StatelessWidget {
  const StampHistoryScreen({
    required this.state,
    required this.onTapWriteReview,
    super.key,
  });

  final StampHistoryState state;
  final void Function(StoreStampStatus status) onTapWriteReview;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('스탬프 현황'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFAF6),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                      '예약 완료 후 리뷰를 작성하면 업장별 스탬프가 적립됩니다. 매장마다 목표 개수와 보상 내용이 다를 수 있습니다.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (state.stampStatuses.isEmpty)
                    const _EmptyStampHistory()
                  else
                    ...state.stampStatuses.map(
                      (status) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _StampHistoryCard(
                          status: status,
                          onTapWriteReview: onTapWriteReview,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _StampHistoryCard extends StatelessWidget {
  const _StampHistoryCard({
    required this.status,
    required this.onTapWriteReview,
  });

  final StoreStampStatus status;
  final void Function(StoreStampStatus status) onTapWriteReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D111827),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  status.storeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: status.isRewardUnlocked
                      ? const Color(0xFFFFE5DA)
                      : const Color(0xFFF4F6F8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status.progressLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: status.isRewardUnlocked
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: status.progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFFFE5DA),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '보상: ${status.rewardTitle}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            status.rewardDescription,
            style: const TextStyle(
              fontSize: 13,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  status.historyStatusMessage,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: status.hasWrittenReview
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              if (!status.hasWrittenReview)
                TextButton(
                  onPressed: () => onTapWriteReview(status),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '리뷰 작성하기',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            status.hasWrittenReview
                ? '리뷰 작성이 완료되어 스탬프가 적립된 상태입니다.'
                : '스탬프 적립을 위해 리뷰를 작성 해 주세요!',
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStampHistory extends StatelessWidget {
  const _EmptyStampHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.card_giftcard_rounded,
            size: 40,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12),
          Text(
            '아직 적립된 스탬프가 없습니다.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '예약 완료 후 리뷰를 작성하면 업장별 스탬프가 적립됩니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
