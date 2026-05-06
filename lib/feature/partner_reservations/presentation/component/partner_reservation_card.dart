import 'package:capstone_2026/core/domain/model/enum/reservation_status.dart';
import 'package:capstone_2026/core/domain/model/reservation/reservation.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/component/partner_reservation_status_badge.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerReservationCard extends StatelessWidget {
  final Reservation reservation;
  final bool isUpdating;
  final bool isGlobalUpdating;
  final void Function(ReservationStatus) onSelectStatus;
  final String Function(DateTime) formatDate;
  final String Function(DateTime) formatDateTime;

  const PartnerReservationCard({
    super.key,
    required this.reservation,
    required this.isUpdating,
    required this.isGlobalUpdating,
    required this.onSelectStatus,
    required this.formatDate,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${formatDate(reservation.bookingDate)}  ${reservation.bookingTime}',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
                PartnerReservationStatusBadge(status: reservation.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '인원 ${reservation.guestCount}명',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              reservation.customerRequest?.trim().isNotEmpty == true
                  ? '요청사항: ${reservation.customerRequest}'
                  : '요청사항 없음',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    reservation.totalPrice > 0
                        ? '예약금 ${reservation.totalPrice}원'
                        : '예약금 없음',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  '갱신 ${formatDateTime(reservation.updatedAt)}',
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<ReservationStatus>(
                enabled: !isUpdating && !isGlobalUpdating,
                onSelected: onSelectStatus,
                itemBuilder: (context) => ReservationStatus.values
                    .map(
                      (status) => PopupMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                    )
                    .toList(),
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isUpdating)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      Text(
                        isUpdating ? '처리 중...' : '상태 변경',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
