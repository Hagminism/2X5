import 'package:capstone_2026/feature/partner_reservations/presentation/component/partner_reservation_card.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/component/partner_reservation_date_filter_chip.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/component/partner_reservation_empty_view.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/component/partner_reservation_status_filter_chips.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/screen/partner_reservations_action.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/screen/partner_reservations_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerReservationsScreen extends StatelessWidget {
  final PartnerReservationsState state;
  final void Function(PartnerReservationsAction action) onAction;

  const PartnerReservationsScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
              child: Text(
                '예약 현황',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Text(
                '관리자 매장 예약을 상태별로 확인하고 처리할 수 있어요.',
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
              ),
            ),
            PartnerReservationStatusFilterChips(
              selectedStatus: state.selectedStatus,
              onSelectStatus: (status) => onAction(
                PartnerReservationsAction.selectStatus(status),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '총 ${state.filteredReservations.length}건',
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
                  ),
                  PartnerReservationDateFilterChip(
                    selectedDate: state.selectedDate,
                    formatDate: _formatDate,
                    onTapDateFilter: () => onAction(
                      const PartnerReservationsAction.tapDateFilter(),
                    ),
                    onClearDate: () => onAction(
                      const PartnerReservationsAction.selectDate(null),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final reservations = state.filteredReservations;
    if (reservations.isEmpty) {
      return PartnerReservationEmptyView(
        onRetry: () => onAction(const PartnerReservationsAction.tapRetry()),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final item = reservations[index];
        return PartnerReservationCard(
          reservation: item,
          isUpdating: state.updatingReservationId == item.id,
          isGlobalUpdating: state.isUpdating,
          formatDate: _formatDate,
          formatDateTime: _formatDateTime,
          onSelectStatus: (status) => onAction(
            PartnerReservationsAction.tapChangeStatus(
              reservationId: item.id,
              status: status,
            ),
          ),
        );
      },
      separatorBuilder: (_, _) => const SizedBox(height: 10),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }

  String _formatDateTime(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month.$day $hour:$minute';
  }
}
