import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element_type.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/component/toolbar/partner_studycafe_layout_toolbar_button.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/screen/partner_studycafe_layout_action.dart';
import 'package:flutter/material.dart';

class PartnerStudyCafeLayoutToolbar extends StatelessWidget {
  final void Function(PartnerStudyCafeLayoutAction action) onAction;

  const PartnerStudyCafeLayoutToolbar({
    super.key,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          PartnerStudyCafeLayoutToolbarButton(
            icon: Icons.event_seat_rounded,
            label: '좌석',
            description: '새 좌석',
            onTap: () => onAction(
              const PartnerStudyCafeLayoutAction.addSeat(),
            ),
          ),
          const SizedBox(width: 10),
          PartnerStudyCafeLayoutToolbarButton(
            icon: Icons.horizontal_rule_rounded,
            label: '파티션',
            description: '칸막이',
            onTap: () => onAction(
              const PartnerStudyCafeLayoutAction.addElement(
                StudyCafeLayoutElementType.partition,
              ),
            ),
          ),
          const SizedBox(width: 10),
          PartnerStudyCafeLayoutToolbarButton(
            icon: Icons.door_front_door_rounded,
            label: '문',
            description: '출입구',
            onTap: () => onAction(
              const PartnerStudyCafeLayoutAction.addElement(
                StudyCafeLayoutElementType.door,
              ),
            ),
          ),
          const SizedBox(width: 10),
          PartnerStudyCafeLayoutToolbarButton(
            icon: Icons.countertops_rounded,
            label: '구조물',
            description: '스낵바 등',
            onTap: () => onAction(
              const PartnerStudyCafeLayoutAction.addElement(
                StudyCafeLayoutElementType.fixture,
              ),
            ),
          ),
          const SizedBox(width: 10),
          PartnerStudyCafeLayoutToolbarButton(
            icon: Icons.align_horizontal_center_rounded,
            label: '가로 정렬',
            description: '선택 항목',
            onTap: () => onAction(
              const PartnerStudyCafeLayoutAction.alignSelectedSeatsHorizontally(),
            ),
          ),
          const SizedBox(width: 10),
          PartnerStudyCafeLayoutToolbarButton(
            icon: Icons.align_vertical_center_rounded,
            label: '세로 정렬',
            description: '선택 항목',
            onTap: () => onAction(
              const PartnerStudyCafeLayoutAction.alignSelectedSeatsVertically(),
            ),
          ),
          const SizedBox(width: 10),
          PartnerStudyCafeLayoutToolbarButton(
            icon: Icons.delete_outline_rounded,
            label: '삭제',
            description: '선택 항목',
            isDanger: true,
            onTap: () {
              onAction(
                const PartnerStudyCafeLayoutAction.removeSelectedSeat(),
              );
              onAction(
                const PartnerStudyCafeLayoutAction.removeSelectedElement(),
              );
            },
          ),
        ],
      ),
    );
  }
}
