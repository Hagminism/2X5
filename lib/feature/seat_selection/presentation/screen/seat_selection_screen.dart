import 'package:capstone_2026/feature/seat_selection/presentation/component/seat_selection_bottom_action_bar.dart';
import 'package:capstone_2026/feature/seat_selection/presentation/component/seat_selection_layout_canvas.dart';
import 'package:capstone_2026/feature/seat_selection/presentation/component/seat_selection_seat_display.dart';
import 'package:capstone_2026/feature/seat_selection/presentation/component/seat_selection_status_legend.dart';
import 'package:capstone_2026/feature/seat_selection/presentation/screen/seat_selection_action.dart';
import 'package:capstone_2026/feature/seat_selection/presentation/screen/seat_selection_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class SeatSelectionScreen extends StatelessWidget {
  final SeatSelectionState state;
  final void Function(SeatSelectionAction action) onAction;

  const SeatSelectionScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedSeatForState(state);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        surfaceTintColor: AppColors.white,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () {
            onAction(const SeatSelectionAction.tapBack());
          },
        ),
        title: const Text(
          '좌석 선택',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          SeatSelectionStatusLegend(
            showLoading: state.isLoading,
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: _buildBody(context),
          ),
          if (selected != null)
            SeatSelectionBottomActionBar(
              selectedSeat: selected,
              onConfirmPressed: () {
                onAction(
                  SeatSelectionAction.tapConfirmSelection(
                    seatId: selected.seatId,
                    seatLabel: seatLabelForDisplay(selected),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final String? errorMessage = state.errorMessage;
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  onAction(const SeatSelectionAction.tapRetry());
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }
    if (state.seats.isEmpty) {
      return const Center(
        child: Text(
          '등록된 좌석이 없습니다.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return SeatSelectionLayoutCanvas(
      elements: state.elements,
      seats: state.seats,
      occupiedSeatIds: state.occupiedSeatIds,
      selectedSeatId: state.selectedSeatId,
      onSeatTap: (String seatId) {
        onAction(SeatSelectionAction.tapSeat(seatId));
      },
    );
  }
}
