import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/component/partner_studycafe_layout_editor_delete_button.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/component/partner_studycafe_layout_editor_sheet_frame.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/screen/partner_studycafe_layout_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

void showPartnerStudyCafeLayoutSeatEditorSheet(
  BuildContext context,
  StudyCafeSeat seat,
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
      return PartnerStudyCafeLayoutSeatEditorSheet(
        seat: seat,
        onAction: onAction,
      );
    },
  );
}

class PartnerStudyCafeLayoutSeatEditorSheet extends StatefulWidget {
  final StudyCafeSeat seat;
  final void Function(PartnerStudyCafeLayoutAction action) onAction;

  const PartnerStudyCafeLayoutSeatEditorSheet({
    super.key,
    required this.seat,
    required this.onAction,
  });

  @override
  State<PartnerStudyCafeLayoutSeatEditorSheet> createState() =>
      _PartnerStudyCafeLayoutSeatEditorSheetState();
}

class _PartnerStudyCafeLayoutSeatEditorSheetState
    extends State<PartnerStudyCafeLayoutSeatEditorSheet> {
  late bool isEnabled = widget.seat.isEnabled;

  @override
  Widget build(BuildContext context) {
    return PartnerStudyCafeLayoutEditorSheetFrame(
      title: '좌석 설정',
      subtitle: '드래그로 위치를 옮기고, 여기서 좌석 이름과 사용 여부를 조정합니다.',
      child: Column(
        children: [
          TextFormField(
            key: ValueKey(widget.seat.seatId),
            initialValue: widget.seat.label,
            decoration: const InputDecoration(labelText: '좌석명'),
            onChanged: (String value) => widget.onAction(
              PartnerStudyCafeLayoutAction.changeSelectedSeatLabel(value),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: isEnabled,
            title: const Text('이 좌석 사용'),
            subtitle: const Text('비활성화하면 고객이 선택할 수 없습니다.'),
            activeThumbColor: AppColors.primary,
            onChanged: (bool value) {
              setState(() {
                isEnabled = value;
              });
              widget.onAction(
                PartnerStudyCafeLayoutAction.toggleSelectedSeatEnabled(value),
              );
            },
          ),
          const SizedBox(height: 16),
          PartnerStudyCafeLayoutEditorDeleteButton(
            label: '좌석 삭제',
            onTap: () {
              widget.onAction(
                const PartnerStudyCafeLayoutAction.removeSelectedSeat(),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
