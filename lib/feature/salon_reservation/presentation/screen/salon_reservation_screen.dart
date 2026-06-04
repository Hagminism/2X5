import 'package:capstone_2026/core/presentation/component/app_bar/custom_app_bar.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/component/salon_reservation_date_selector.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/component/salon_reservation_service_list.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/component/salon_reservation_slot_grid.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/component/salon_reservation_submit_bar.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_action.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class SalonReservationScreen extends StatelessWidget {
  final SalonReservationState state;
  final bool canSubmit;
  final void Function(SalonReservationAction action) onAction;

  const SalonReservationScreen({
    super.key,
    required this.state,
    required this.canSubmit,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: '날짜와 시간을 선택해 주세요',
        showBackButton: true,
        onTap: () {
          onAction(const SalonReservationAction.tapBack());
        },
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody(context)),
          SalonReservationSubmitBar(
            enabled: canSubmit,
            isSubmitting: state.isSubmitting,
            onAction: onAction,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = state.loadError;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  onAction(const SalonReservationAction.tapRetry());
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }
    if (state.designers.isEmpty || state.services.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '예약 가능한 디자이너 또는 시술 정보가 없습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final selectedDesigner = state.designers.firstWhere(
      (d) => d.id == state.selectedDesignerId,
      orElse: () => state.designers.first,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '예약 일정 및 시술 선택',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '선택하신 디자이너의 예약 가능 시간을 확인해 주세요.',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 선택된 디자이너 정보 카드 (고정)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.white,
                    backgroundImage: selectedDesigner.imageUrl.isEmpty
                        ? null
                        : NetworkImage(selectedDesigner.imageUrl),
                    child: selectedDesigner.imageUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            color: AppColors.textSecondary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedDesigner.name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedDesigner.introduction.isEmpty
                              ? '전문 헤어 디자이너'
                              : selectedDesigner.introduction,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SectionHeader(
              title: '날짜 및 시간 선택',
              subtitle: '방문하실 날짜와 시간을 선택해주세요.',
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SalonReservationDateSelector(
              selectedDate: state.selectedDate,
              onAction: onAction,
            ),
          ),
          const SizedBox(height: 32),
          const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
          const SizedBox(height: 12),
          SalonReservationSlotGrid(
            slots: state.slots,
            selectedStartAt: state.selectedStartAt,
            onAction: onAction,
          ),
          const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SectionHeader(
              title: '시술 선택',
              subtitle: '받으실 시술을 모두 선택해주세요.',
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SalonReservationServiceList(
              services: state.services,
              selectedServiceIds: state.selectedServiceIds,
              onAction: onAction,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
