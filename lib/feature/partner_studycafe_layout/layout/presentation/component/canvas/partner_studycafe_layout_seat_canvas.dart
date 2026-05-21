import 'package:capstone_2026/feature/partner_studycafe_layout/layout/presentation/component/canvas/partner_studycafe_layout_editable_element.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/layout/presentation/component/canvas/partner_studycafe_layout_editable_seat.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/layout/presentation/screen/partner_studycafe_layout_action.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/layout/presentation/screen/partner_studycafe_layout_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class PartnerStudyCafeLayoutSeatCanvas extends StatefulWidget {
  final PartnerStudyCafeLayoutState state;
  final void Function(PartnerStudyCafeLayoutAction action) onAction;

  const PartnerStudyCafeLayoutSeatCanvas({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  State<PartnerStudyCafeLayoutSeatCanvas> createState() =>
      _PartnerStudyCafeLayoutSeatCanvasState();
}

class _PartnerStudyCafeLayoutSeatCanvasState
    extends State<PartnerStudyCafeLayoutSeatCanvas> {
  static const double _canvasAspectRatio = 650 / 400;
  Offset? _selectionStart;
  Offset? _selectionCurrent;

  Rect? get _selectionRect {
    final start = _selectionStart;
    final current = _selectionCurrent;
    if (start == null || current == null) {
      return null;
    }
    return Rect.fromPoints(start, current);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 40;
        final canvasWidth = (availableWidth - 24)
            .clamp(280.0, 560.0)
            .toDouble();
        final canvasHeight = canvasWidth * _canvasAspectRatio;
        final seatSize = (canvasWidth * 0.085).clamp(30.0, 44.0).toDouble();

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: canvasWidth,
              height: canvasHeight,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  widget.onAction(
                    const PartnerStudyCafeLayoutAction.selectSeats([]),
                  );
                  widget.onAction(
                    const PartnerStudyCafeLayoutAction.selectElements([]),
                  );
                },
                onPanStart: (DragStartDetails details) {
                  setState(() {
                    _selectionStart = details.localPosition;
                    _selectionCurrent = details.localPosition;
                  });
                },
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    _selectionCurrent = details.localPosition;
                  });
                },
                onPanEnd: (DragEndDetails details) {
                  _selectItemsInRect(
                    canvasWidth: canvasWidth,
                    canvasHeight: canvasHeight,
                    seatSize: seatSize,
                  );
                  setState(() {
                    _selectionStart = null;
                    _selectionCurrent = null;
                  });
                },
                child: Stack(
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
                    for (final element in widget.state.elements)
                      PartnerStudyCafeLayoutEditableElement(
                        element: element,
                        isSelected: widget.state.selectedElementIds.contains(
                          element.elementId,
                        ),
                        canvasWidth: canvasWidth,
                        canvasHeight: canvasHeight,
                        onAction: widget.onAction,
                      ),
                    for (final seat in widget.state.seats)
                      PartnerStudyCafeLayoutEditableSeat(
                        seat: seat,
                        isSelected: widget.state.selectedSeatIds.contains(
                          seat.seatId,
                        ),
                        canvasWidth: canvasWidth,
                        canvasHeight: canvasHeight,
                        seatSize: seatSize,
                        onAction: widget.onAction,
                      ),
                    if (_selectionRect case final Rect rect)
                      Positioned.fromRect(
                        rect: rect,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              border: Border.all(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectItemsInRect({
    required double canvasWidth,
    required double canvasHeight,
    required double seatSize,
  }) {
    final rect = _selectionRect;
    if (rect == null || rect.shortestSide < 8) {
      return;
    }
    final movableWidth = canvasWidth - seatSize;
    final movableHeight = canvasHeight - seatSize;
    final selectedSeatIds = widget.state.seats
        .where((seat) {
          final seatRect = Rect.fromLTWH(
            seat.x.clamp(0, 1).toDouble() * movableWidth,
            seat.y.clamp(0, 1).toDouble() * movableHeight,
            seatSize,
            seatSize,
          );
          return rect.overlaps(seatRect);
        })
        .map((seat) => seat.seatId)
        .toList();
    final selectedElementIds = widget.state.elements
        .where((element) {
          final width = (canvasWidth * element.width)
              .clamp(16.0, canvasWidth)
              .toDouble();
          final height = (canvasHeight * element.height)
              .clamp(10.0, canvasHeight)
              .toDouble();
          final elMovableWidth = canvasWidth - width;
          final elMovableHeight = canvasHeight - height;
          final elementRect = Rect.fromLTWH(
            element.x.clamp(0, 1).toDouble() * elMovableWidth,
            element.y.clamp(0, 1).toDouble() * elMovableHeight,
            width,
            height,
          );
          return rect.overlaps(elementRect);
        })
        .map((element) => element.elementId)
        .toList();

    widget.onAction(PartnerStudyCafeLayoutAction.selectSeats(selectedSeatIds));
    widget.onAction(
      PartnerStudyCafeLayoutAction.selectElements(selectedElementIds),
    );
  }
}
