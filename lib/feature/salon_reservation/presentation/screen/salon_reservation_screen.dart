import 'package:capstone_2026/feature/salon_reservation/presentation/component/salon_reservation_date_selector.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/component/salon_reservation_designer_list.dart';
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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        surfaceTintColor: AppColors.white,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () {
            onAction(const SalonReservationAction.tapBack());
          },
        ),
        title: const Text(
          '미용실 예약',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
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

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '디자이너와 시술을 선택해 주세요',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${state.settings.slotMinutes}분 단위로 예약을 받으며, 같은 시작 시간에는 디자이너별로 1명만 예약할 수 있어요.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 24),
        _SectionTitle(title: '디자이너'),
        const SizedBox(height: 12),
        SalonReservationDesignerList(
          designers: state.designers,
          selectedDesignerId: state.selectedDesignerId,
          onAction: onAction,
        ),
        const SizedBox(height: 28),
        _SectionTitle(title: '시술'),
        const SizedBox(height: 12),
        SalonReservationServiceList(
          services: state.services,
          selectedServiceId: state.selectedServiceId,
          onAction: onAction,
        ),
        const SizedBox(height: 18),
        _SectionTitle(title: '날짜'),
        const SizedBox(height: 12),
        SalonReservationDateSelector(
          selectedDate: state.selectedDate,
          onAction: onAction,
        ),
        const SizedBox(height: 28),
        _SectionTitle(title: '시간'),
        const SizedBox(height: 12),
        SalonReservationSlotGrid(
          slots: state.slots,
          selectedStartAt: state.selectedStartAt,
          onAction: onAction,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.subtitle.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
