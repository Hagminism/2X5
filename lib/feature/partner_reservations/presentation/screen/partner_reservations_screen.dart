import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/component/partner_reservation_card.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/component/partner_reservation_empty_view.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/component/partner_reservation_settings_entry_card.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/component/partner_reservation_status_filter_chips.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/component/partner_reservations_header.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/component/partner_reservations_summary_row.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/screen/partner_reservations_action.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/screen/partner_reservations_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartnerReservationsScreen extends StatelessWidget {
  final PartnerReservationsState state;
  final void Function(PartnerReservationsAction) onAction;

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PartnerReservationsHeader(),
              PartnerReservationSettingsEntryCard(
                onTapSettings: () {
                  context.push(
                    '${Routes.partnerReservations}/${Routes.partnerReservationSlotSettings}',
                  );
                },
              ),
              PartnerReservationStatusFilterChips(
                selectedStatus: state.selectedStatus,
                onSelectStatus: (status) => onAction(
                  PartnerReservationsAction.selectStatus(status),
                ),
              ),
              PartnerReservationsSummaryRow(
                totalCount: state.filteredReservations.length,
                selectedDate: state.selectedDate,
                formatDate: _formatDate,
                onTapDateFilter: () => onAction(
                  const PartnerReservationsAction.tapDateFilter(),
                ),
                onClearDate: () => onAction(
                  const PartnerReservationsAction.selectDate(null),
                ),
              ),
              const SizedBox(height: 8),
              _buildBody(state: state, onAction: onAction),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required PartnerReservationsState state,
    required void Function(PartnerReservationsAction) onAction,
  }) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
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
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
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
