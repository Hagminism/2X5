import 'package:capstone_2026/core/utils/date_format_util.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/domain/model/user_reservation_history_item.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/component/reservation_history_status_badge.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReservationHistoryCard extends StatelessWidget {
  final UserReservationHistoryItem item;
  final VoidCallback onTap;

  const ReservationHistoryCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheduleText = _formatSchedule(item.scheduledAt);
    final categoryText = item.categoryLabel.trim().isNotEmpty
        ? item.categoryLabel.trim()
        : item.type.label;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.storeName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    ReservationHistoryStatusBadge(status: item.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  categoryText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  scheduleText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.summary,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatSchedule(DateTime scheduledAt) {
    if (scheduledAt.millisecondsSinceEpoch <= 0) {
      return '일정 정보 없음';
    }

    final dateText = formatDotDate(scheduledAt);
    final timeText = DateFormat('HH:mm').format(scheduledAt);
    if (dateText.isEmpty) {
      return timeText;
    }

    return '$dateText · $timeText';
  }
}
