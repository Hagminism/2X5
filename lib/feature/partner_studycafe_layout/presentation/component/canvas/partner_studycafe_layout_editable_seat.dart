import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/component/editor/partner_studycafe_layout_seat_editor_sheet.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/screen/partner_studycafe_layout_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class PartnerStudyCafeLayoutEditableSeat extends StatelessWidget {
  final StudyCafeSeat seat;
  final bool isSelected;
  final double canvasWidth;
  final double canvasHeight;
  final double seatSize;
  final void Function(PartnerStudyCafeLayoutAction action) onAction;

  const PartnerStudyCafeLayoutEditableSeat({
    super.key,
    required this.seat,
    required this.isSelected,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.seatSize,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = !seat.isEnabled
        ? AppColors.authProviderButton
        : (isSelected ? AppColors.primary : AppColors.white);
    final foregroundColor = isSelected
        ? AppColors.white
        : AppColors.textPrimary;
    final movableWidth = canvasWidth - seatSize;
    final movableHeight = canvasHeight - seatSize;
    final left = seat.x.clamp(0, 1).toDouble() * movableWidth;
    final top = seat.y.clamp(0, 1).toDouble() * movableHeight;

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () => onAction(
          PartnerStudyCafeLayoutAction.selectSeat(seat.seatId),
        ),
        onLongPress: () {
          onAction(PartnerStudyCafeLayoutAction.selectSeat(seat.seatId));
          showPartnerStudyCafeLayoutSeatEditorSheet(context, seat, onAction);
        },
        onPanUpdate: (DragUpdateDetails details) => onAction(
          PartnerStudyCafeLayoutAction.moveSeat(
            seatId: seat.seatId,
            deltaX: movableWidth == 0 ? 0 : details.delta.dx / movableWidth,
            deltaY: movableHeight == 0 ? 0 : details.delta.dy / movableHeight,
          ),
        ),
        child: Container(
          width: seatSize,
          height: seatSize,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              seat.label,
              style: TextStyle(
                color: foregroundColor,
                fontSize: (seatSize * 0.35).clamp(11.0, 15.0).toDouble(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
