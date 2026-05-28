import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element_type.dart';
import 'package:capstone_2026/feature/partner_store_layout/presentation/screen/partner_store_layout_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerStoreLayoutToolbar extends StatelessWidget {
  final void Function(PartnerStoreLayoutAction) onAction;

  const PartnerStoreLayoutToolbar({
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
          PartnerStoreLayoutToolbarButton(
            icon: Icons.event_seat_rounded,
            label: '테이블',
            description: '새 테이블',
            onTap: () => onAction(
              const PartnerStoreLayoutAction.addSeat(),
            ),
          ),
          const SizedBox(width: 10),
          PartnerStoreLayoutToolbarButton(
            icon: Icons.horizontal_rule_rounded,
            label: '파티션',
            description: '칸막이',
            onTap: () => onAction(
              const PartnerStoreLayoutAction.addElement(
                StudyCafeLayoutElementType.partition,
              ),
            ),
          ),
          const SizedBox(width: 10),
          PartnerStoreLayoutToolbarButton(
            icon: Icons.door_front_door_rounded,
            label: '문',
            description: '출입구',
            onTap: () => onAction(
              const PartnerStoreLayoutAction.addElement(
                StudyCafeLayoutElementType.door,
              ),
            ),
          ),
          const SizedBox(width: 10),
          PartnerStoreLayoutToolbarButton(
            icon: Icons.countertops_rounded,
            label: '구조물',
            description: '카운터 등',
            onTap: () => onAction(
              const PartnerStoreLayoutAction.addElement(
                StudyCafeLayoutElementType.fixture,
              ),
            ),
          ),
          const SizedBox(width: 10),
          PartnerStoreLayoutToolbarButton(
            icon: Icons.align_horizontal_center_rounded,
            label: '가로 정렬',
            description: '선택 항목',
            onTap: () => onAction(
              const PartnerStoreLayoutAction.alignSelectedSeatsHorizontally(),
            ),
          ),
          const SizedBox(width: 10),
          PartnerStoreLayoutToolbarButton(
            icon: Icons.align_vertical_center_rounded,
            label: '세로 정렬',
            description: '선택 항목',
            onTap: () => onAction(
              const PartnerStoreLayoutAction.alignSelectedSeatsVertically(),
            ),
          ),
          const SizedBox(width: 10),
          PartnerStoreLayoutToolbarButton(
            icon: Icons.copy_all_outlined,
            label: '테이블 복사',
            description: '선택한 테이블',
            onTap: () => onAction(
              const PartnerStoreLayoutAction.duplicateSelectedSeats(),
            ),
          ),
          const SizedBox(width: 10),
          PartnerStoreLayoutToolbarButton(
            icon: Icons.delete_outline_rounded,
            label: '삭제',
            description: '선택 항목',
            isDanger: true,
            onTap: () {
              onAction(
                const PartnerStoreLayoutAction.removeSelectedSeat(),
              );
              onAction(
                const PartnerStoreLayoutAction.removeSelectedElement(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PartnerStoreLayoutToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isDanger;
  final void Function() onTap;

  const PartnerStoreLayoutToolbarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? AppColors.danger : AppColors.primary;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 150,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Ink(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
