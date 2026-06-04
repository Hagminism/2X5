import 'package:capstone_2026/core/presentation/component/app_bar/custom_app_bar.dart';
import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/core/presentation/component/input/reservation_customer_request_field.dart';
import 'package:capstone_2026/core/util/salon_booking_time.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/screen/salon_reservation_confirm_action.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/screen/salon_reservation_confirm_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class SalonReservationConfirmScreen extends StatelessWidget {
  final SalonReservationConfirmState state;
  final bool canConfirm;
  final void Function(SalonReservationConfirmAction action) onAction;

  const SalonReservationConfirmScreen({
    super.key,
    required this.state,
    required this.canConfirm,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.white,
          appBar: CustomAppBar(
            title: '예약 확정',
            showBackButton: true,
            onTap: () {
              onAction(const SalonReservationConfirmAction.tapBack());
            },
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                text: state.isSubmitting ? '처리 중...' : '예약 확정',
                onTap: canConfirm && !state.isSubmitting
                    ? () {
                        onAction(
                          const SalonReservationConfirmAction.tapConfirm(),
                        );
                      }
                    : () {},
              ),
            ),
          ),
          body: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Text(
                          '예약 내역을 확인해 주세요.',
                          style: AppTextStyles.subtitle,
                        ),
                      ),
                      if (state.submitError != null) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            state.submitError!,
                            style: AppTextStyles.bodySecondary.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.designer != null)
                              Text(
                                '디자이너: ${state.designer!.name}',
                                style: AppTextStyles.body,
                              ),
                            const SizedBox(height: 8),
                            Text(
                              '일정: ${SalonBookingTime.seoulKoreanDateTimeLabel(state.selectedDateTime)}',
                              style: AppTextStyles.body,
                            ),
                            const SizedBox(height: 8),
                            if (state.services.isNotEmpty)
                              Text(
                                '선택 시술: ${state.services.map((s) => s.name).join(', ')}',
                                style: AppTextStyles.body,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ReservationCustomerRequestField(
                        value: state.customerRequest,
                        onChanged: (value) {
                          onAction(
                            SalonReservationConfirmAction.changeCustomerRequest(
                              value,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
        ),
        if (state.isSubmitting)
          ModalBarrier(
            dismissible: false,
            color: AppColors.black.withValues(alpha: 0.2588),
          ),
        if (state.isSubmitting)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
      ],
    );
  }
}
