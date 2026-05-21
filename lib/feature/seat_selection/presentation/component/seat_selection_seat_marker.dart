import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:capstone_2026/feature/seat_selection/presentation/component/seat_selection_seat_display.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class SeatSelectionSeatMarker extends StatelessWidget {
  final StudyCafeSeat seat;
  final double canvasWidth;
  final double canvasHeight;
  final double seatSize;
  final bool isOccupied;
  final bool isSelected;
  final void Function(String seatId) onSeatTap;

  const SeatSelectionSeatMarker({
    super.key,
    required this.seat,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.seatSize,
    required this.isOccupied,
    required this.isSelected,
    required this.onSeatTap,
  });

  @override
  Widget build(BuildContext context) {
    final double movableWidth = canvasWidth - seatSize;
    final double movableHeight = canvasHeight - seatSize;
    final double left = seat.x.clamp(0, 1).toDouble() * movableWidth;
    final double top = seat.y.clamp(0, 1).toDouble() * movableHeight;
    final String seatLabelText = seatLabelForDisplay(seat);

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () {
          if (isOccupied) {
            return;
          }
          onSeatTap(seat.seatId);
        },
        child: Container(
          width: seatSize,
          height: seatSize,
          decoration: BoxDecoration(
            color: isOccupied
                ? AppColors.authProviderButton
                : (isSelected ? AppColors.primary : AppColors.white),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              seatLabelText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontSize: (canvasWidth * 0.03).clamp(10.0, 12.0).toDouble(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
