import 'package:capstone_2026/core/util/salon_booking_time.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/screen/salon_reservation_confirm_action.dart';
import 'package:capstone_2026/feature/salon_reservation_confirm/presentation/screen/salon_reservation_confirm_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class SalonReservationConfirmScreen extends StatelessWidget {
  final SalonReservationConfirmState state;
  final void Function(SalonReservationConfirmAction) onAction;

  const SalonReservationConfirmScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('예약 확정', style: TextStyle(fontWeight: FontWeight.bold)),
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => onAction(const SalonReservationConfirmAction.tapBack()),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: state.isLoading || state.isSubmitting
                ? null
                : () => onAction(const SalonReservationConfirmAction.tapConfirm()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            ),
            child: state.isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('예약금 안내 확인 및 예약 확정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('예약 내역을 확인해주세요.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  if (state.designer != null)
                    Text('디자이너: ${state.designer!.name}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('일정: ${_formatDate(state.selectedDateTime)}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  if (state.services.isNotEmpty)
                    Text('선택 시술: ${state.services.map((s) => s.name).join(', ')}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('예약금 안내', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          '본 예약은 확정 후 매장 방문 시 예약금을 결제하셔야 최종 완료될 수 있습니다. 노쇼 방지를 위해 예약금 정책이 적용됩니다.',
                          style: TextStyle(color: Colors.black54, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(String isoDate) {
    return SalonBookingTime.seoulKoreanDateTimeLabel(isoDate);
  }
}
