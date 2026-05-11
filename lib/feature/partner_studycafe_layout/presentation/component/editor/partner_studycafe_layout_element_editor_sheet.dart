import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/component/editor/partner_studycafe_layout_editor_delete_button.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/component/editor/partner_studycafe_layout_editor_sheet_frame.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/screen/partner_studycafe_layout_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

void showPartnerStudyCafeLayoutElementEditorSheet(
  BuildContext context,
  StudyCafeLayoutElement element,
  void Function(PartnerStudyCafeLayoutAction action) onAction,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) {
      return PartnerStudyCafeLayoutElementEditorSheet(
        element: element,
        onAction: onAction,
      );
    },
  );
}

class PartnerStudyCafeLayoutElementEditorSheet extends StatelessWidget {
  final StudyCafeLayoutElement element;
  final void Function(PartnerStudyCafeLayoutAction action) onAction;

  const PartnerStudyCafeLayoutElementEditorSheet({
    super.key,
    required this.element,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return PartnerStudyCafeLayoutEditorSheetFrame(
      title: '${element.type.label} 설정',
      subtitle: '드래그로 위치를 옮기고, 여기서 크기와 표시 이름을 조정합니다.',
      child: Column(
        children: [
          TextFormField(
            key: ValueKey('element-label-${element.elementId}'),
            initialValue: element.label,
            decoration: const InputDecoration(labelText: '표시 이름'),
            onChanged: (String value) => onAction(
              PartnerStudyCafeLayoutAction.changeSelectedElementLabel(value),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey(
                    'element-width-${element.elementId}-${element.width}',
                  ),
                  initialValue: (element.width * 100).round().toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '너비(%)'),
                  onChanged: (String value) => onAction(
                    PartnerStudyCafeLayoutAction.changeSelectedElementWidth(
                      value,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: ValueKey(
                    'element-height-${element.elementId}-${element.height}',
                  ),
                  initialValue: (element.height * 100).round().toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '높이(%)'),
                  onChanged: (String value) => onAction(
                    PartnerStudyCafeLayoutAction.changeSelectedElementHeight(
                      value,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey(
              'element-rotation-${element.elementId}-${element.rotation}',
            ),
            initialValue: element.rotation.round().toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '회전(도)'),
            onChanged: (String value) => onAction(
              PartnerStudyCafeLayoutAction.changeSelectedElementRotation(value),
            ),
          ),
          const SizedBox(height: 16),
          PartnerStudyCafeLayoutEditorDeleteButton(
            label: '구조물 삭제',
            onTap: () {
              onAction(
                const PartnerStudyCafeLayoutAction.removeSelectedElement(),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
