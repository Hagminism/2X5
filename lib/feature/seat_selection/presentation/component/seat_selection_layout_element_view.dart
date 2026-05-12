import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element_type.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class SeatSelectionLayoutElementView extends StatelessWidget {
  final StudyCafeLayoutElement element;
  final double canvasWidth;
  final double canvasHeight;

  const SeatSelectionLayoutElementView({
    super.key,
    required this.element,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  @override
  Widget build(BuildContext context) {
    final double width =
        (canvasWidth * element.width).clamp(16.0, canvasWidth).toDouble();
    final double height =
        (canvasHeight * element.height).clamp(10.0, canvasHeight).toDouble();
    final double movableWidth = canvasWidth - width;
    final double movableHeight = canvasHeight - height;
    final double left =
        element.x.clamp(0, 1).toDouble() * movableWidth;
    final double top = element.y.clamp(0, 1).toDouble() * movableHeight;

    final BoxDecoration decoration = switch (element.type) {
      StudyCafeLayoutElementType.partition => BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
      StudyCafeLayoutElementType.door => BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(999),
        ),
      StudyCafeLayoutElementType.fixture => BoxDecoration(
          color: AppColors.surfaceMuted,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
    };

    final Color labelColor = switch (element.type) {
      StudyCafeLayoutElementType.door => AppColors.primary,
      StudyCafeLayoutElementType.partition => AppColors.textPrimary,
      StudyCafeLayoutElementType.fixture => AppColors.textPrimary,
    };
    final double labelFontSize =
        (canvasWidth * 0.028).clamp(10.0, 13.0).toDouble();

    return Positioned(
      top: top,
      left: left,
      child: Transform.rotate(
        angle: element.rotation * 3.1415926535 / 180,
        child: Container(
          width: width,
          height: height,
          decoration: decoration,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            element.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: labelColor,
              fontSize: labelFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
