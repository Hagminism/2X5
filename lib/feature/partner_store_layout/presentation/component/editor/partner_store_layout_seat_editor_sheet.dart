import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/layout/presentation/component/editor/partner_studycafe_layout_editor_delete_button.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/layout/presentation/component/editor/partner_studycafe_layout_editor_sheet_frame.dart';
import 'package:capstone_2026/feature/partner_store_layout/presentation/screen/partner_store_layout_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

void showPartnerStoreLayoutSeatEditorSheet(
  BuildContext context,
  StudyCafeSeat seat,
  void Function(PartnerStoreLayoutAction action) onAction,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) {
      return PartnerStoreLayoutSeatEditorSheet(
        seat: seat,
        onAction: onAction,
      );
    },
  );
}

class PartnerStoreLayoutSeatEditorSheet extends StatefulWidget {
  final StudyCafeSeat seat;
  final void Function(PartnerStoreLayoutAction action) onAction;

  const PartnerStoreLayoutSeatEditorSheet({
    super.key,
    required this.seat,
    required this.onAction,
  });

  @override
  State<PartnerStoreLayoutSeatEditorSheet> createState() =>
      _PartnerStoreLayoutSeatEditorSheetState();
}

class _PartnerStoreLayoutSeatEditorSheetState
    extends State<PartnerStoreLayoutSeatEditorSheet> {
  late bool isEnabled = widget.seat.isEnabled;

  @override
  Widget build(BuildContext context) {
    return PartnerStudyCafeLayoutEditorSheetFrame(
      title: '테이블 설정',
      subtitle: '드래그로 위치를 옮기고, 여기서 테이블 이름과 사용 여부를 조정합니다.',
      child: Column(
        children: [
          TextFormField(
            key: ValueKey(widget.seat.seatId),
            initialValue: widget.seat.label,
            decoration: const InputDecoration(labelText: '테이블명'),
            onChanged: (String value) => widget.onAction(
              PartnerStoreLayoutAction.changeSelectedSeatLabel(value),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: isEnabled,
            title: const Text('이 테이블 사용'),
            subtitle: const Text('비활성화하면 고객 화면에 표시되지 않습니다.'),
            activeThumbColor: AppColors.primary,
            onChanged: (bool value) {
              setState(() {
                isEnabled = value;
              });
              widget.onAction(
                PartnerStoreLayoutAction.toggleSelectedSeatEnabled(value),
              );
            },
          ),
          const SizedBox(height: 16),
          PartnerStudyCafeLayoutEditorDeleteButton(
            label: '테이블 삭제',
            onTap: () {
              widget.onAction(
                const PartnerStoreLayoutAction.removeSelectedSeat(),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
