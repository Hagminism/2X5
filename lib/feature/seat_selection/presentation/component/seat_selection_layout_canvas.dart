import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:capstone_2026/feature/seat_selection/presentation/component/seat_selection_layout_element_view.dart';
import 'package:capstone_2026/feature/seat_selection/presentation/component/seat_selection_seat_marker.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class SeatSelectionLayoutCanvas extends StatelessWidget {
  static const double _kCanvasAspectRatio = 650 / 400;

  final List<StudyCafeLayoutElement> elements;
  final List<StudyCafeSeat> seats;
  final List<String> occupiedSeatIds;
  final String? selectedSeatId;
  final void Function(String seatId) onSeatTap;

  const SeatSelectionLayoutCanvas({
    super.key,
    required this.elements,
    required this.seats,
    required this.occupiedSeatIds,
    required this.selectedSeatId,
    required this.onSeatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width - 32;
          final double canvasWidth = (availableWidth - 24)
              .clamp(280.0, 560.0)
              .toDouble();
          final double canvasHeight = canvasWidth * _kCanvasAspectRatio;
          final double seatSize = (canvasWidth * 0.085)
              .clamp(30.0, 44.0)
              .toDouble();

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: canvasWidth,
                    height: canvasHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          for (final StudyCafeLayoutElement element in elements)
                            SeatSelectionLayoutElementView(
                              element: element,
                              canvasWidth: canvasWidth,
                              canvasHeight: canvasHeight,
                            ),
                          for (final StudyCafeSeat seat in seats)
                            SeatSelectionSeatMarker(
                              seat: seat,
                              canvasWidth: canvasWidth,
                              canvasHeight: canvasHeight,
                              seatSize: seatSize,
                              isOccupied:
                                  occupiedSeatIds.contains(seat.seatId) ||
                                  !seat.isEnabled,
                              isSelected: selectedSeatId == seat.seatId,
                              onSeatTap: onSeatTap,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
