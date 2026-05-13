import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalonReservationServiceList extends StatelessWidget {
  final List<SalonService> services;
  final String? selectedServiceId;
  final void Function(SalonReservationAction action) onAction;

  const SalonReservationServiceList({
    super.key,
    required this.services,
    required this.selectedServiceId,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern();
    return Column(
      children: services.map((service) {
        final selected = service.id == selectedServiceId;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              onAction(SalonReservationAction.selectService(service.id));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (service.description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            service.description,
                            style: AppTextStyles.caption,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          '${service.durationMinutes}분 · ${formatter.format(service.price)}원',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
