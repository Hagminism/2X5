import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/layout/presentation/component/canvas/partner_studycafe_layout_element_style.dart';
import 'package:capstone_2026/feature/partner_store_layout/presentation/component/editor/partner_store_layout_element_editor_sheet.dart';
import 'package:capstone_2026/feature/partner_store_layout/presentation/screen/partner_store_layout_action.dart';
import 'package:flutter/material.dart';

class PartnerStoreLayoutEditableElement extends StatelessWidget {
  final StudyCafeLayoutElement element;
  final bool isSelected;
  final double canvasWidth;
  final double canvasHeight;
  final void Function(PartnerStoreLayoutAction action) onAction;

  const PartnerStoreLayoutEditableElement({
    super.key,
    required this.element,
    required this.isSelected,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final width = (canvasWidth * element.width)
        .clamp(16.0, canvasWidth)
        .toDouble();
    final height = (canvasHeight * element.height)
        .clamp(10.0, canvasHeight)
        .toDouble();
    final movableWidth = canvasWidth - width;
    final movableHeight = canvasHeight - height;
    final left = element.x.clamp(0, 1).toDouble() * movableWidth;
    final top = element.y.clamp(0, 1).toDouble() * movableHeight;
    final style = PartnerStudyCafeLayoutElementStyle.fromType(
      element.type,
      isSelected,
    );

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () => onAction(
          PartnerStoreLayoutAction.selectElement(element.elementId),
        ),
        onLongPress: () {
          onAction(
            PartnerStoreLayoutAction.selectElement(element.elementId),
          );
          showPartnerStoreLayoutElementEditorSheet(
            context,
            element,
            onAction,
          );
        },
        onPanUpdate: (DragUpdateDetails details) => onAction(
          PartnerStoreLayoutAction.moveElement(
            elementId: element.elementId,
            deltaX: movableWidth == 0 ? 0 : details.delta.dx / movableWidth,
            deltaY: movableHeight == 0 ? 0 : details.delta.dy / movableHeight,
          ),
        ),
        child: Transform.rotate(
          angle: element.rotation * 3.1415926535 / 180,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: style.backgroundColor,
              border: Border.all(
                color: style.borderColor,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(style.borderRadius),
            ),
            child: Center(
              child: Text(
                element.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: style.textColor,
                  fontSize: (canvasWidth * 0.028).clamp(10.0, 13.0).toDouble(),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
