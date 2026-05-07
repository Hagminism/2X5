import 'package:capstone_2026/feature/partner_reservations/presentation/component/partner_reservation_date_filter_chip.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerReservationsSummaryRow extends StatelessWidget {
  final int totalCount;
  final DateTime? selectedDate;
  final String Function(DateTime) formatDate;
  final VoidCallback onTapDateFilter;
  final VoidCallback onClearDate;

  const PartnerReservationsSummaryRow({
    super.key,
    required this.totalCount,
    required this.selectedDate,
    required this.formatDate,
    required this.onTapDateFilter,
    required this.onClearDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '총 $totalCount건',
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
          ),
          PartnerReservationDateFilterChip(
            selectedDate: selectedDate,
            formatDate: formatDate,
            onTapDateFilter: onTapDateFilter,
            onClearDate: onClearDate,
          ),
        ],
      ),
    );
  }
}
