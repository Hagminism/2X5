import 'package:capstone_2026/core/domain/model/enum/reservation_status.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerReservationStatusFilterChips extends StatelessWidget {
  final ReservationStatus? selectedStatus;
  final void Function(ReservationStatus?) onSelectStatus;

  const PartnerReservationStatusFilterChips({
    super.key,
    required this.selectedStatus,
    required this.onSelectStatus,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatusChip(
            label: '전체',
            selected: selectedStatus == null,
            onTap: () => onSelectStatus(null),
          ),
          const SizedBox(width: 8),
          ...ReservationStatus.values.map((status) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildStatusChip(
                label: status.label,
                selected: selectedStatus == status,
                onTap: () => onSelectStatus(status),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required bool selected,
    required void Function() onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      backgroundColor: AppColors.surfaceMuted,
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
      ),
      labelStyle: AppTextStyles.label.copyWith(
        color: selected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}
