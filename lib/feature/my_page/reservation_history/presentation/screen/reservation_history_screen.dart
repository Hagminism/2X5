import 'package:capstone_2026/feature/my_page/reservation_history/presentation/component/reservation_history_card.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/component/reservation_history_empty_view.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_action.dart';
import 'package:capstone_2026/feature/my_page/reservation_history/presentation/screen/reservation_history_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class ReservationHistoryScreen extends StatelessWidget {
  final ReservationHistoryState state;
  final void Function(ReservationHistoryAction action) onAction;

  const ReservationHistoryScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              '이용 내역',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            surfaceTintColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () {
                onAction(const ReservationHistoryAction.tapBack());
              },
            ),
          ),
          body: SafeArea(
            child: state.isLoading && state.items.isEmpty
                ? const SizedBox.shrink()
                : state.items.isEmpty
                ? const ReservationHistoryEmptyView()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return ReservationHistoryCard(
                        item: item,
                        onTap: () {
                          onAction(
                            ReservationHistoryAction.tapReservationItem(
                              storeId: item.storeId,
                            ),
                          );
                        },
                        onTapReview: () {
                          onAction(
                            ReservationHistoryAction.tapReview(
                              storeId: item.storeId,
                              storeName: item.storeName,
                              reservationId: item.id,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
        if (state.isLoading)
          ModalBarrier(
            dismissible: false,
            color: AppColors.black.withValues(alpha: 0.2588),
          ),
        if (state.isLoading)
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }
}
