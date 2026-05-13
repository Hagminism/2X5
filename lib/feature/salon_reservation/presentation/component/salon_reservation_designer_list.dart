import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class SalonReservationDesignerList extends StatelessWidget {
  final List<SalonDesigner> designers;
  final String? selectedDesignerId;
  final void Function(SalonReservationAction action) onAction;

  const SalonReservationDesignerList({
    super.key,
    required this.designers,
    required this.selectedDesignerId,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: designers.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final designer = designers[index];
          final selected = designer.id == selectedDesignerId;
          return _DesignerCard(
            designer: designer,
            selected: selected,
            onTap: () {
              onAction(SalonReservationAction.selectDesigner(designer.id));
            },
          );
        },
      ),
    );
  }
}

class _DesignerCard extends StatelessWidget {
  final SalonDesigner designer;
  final bool selected;
  final VoidCallback onTap;

  const _DesignerCard({
    required this.designer,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.surfaceMuted,
                  backgroundImage: designer.imageUrl.isEmpty
                      ? null
                      : NetworkImage(designer.imageUrl),
                  child: designer.imageUrl.isEmpty
                      ? const Icon(Icons.person, color: AppColors.textSecondary)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    designer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              designer.introduction.isEmpty
                  ? '소개 문구가 없습니다.'
                  : designer.introduction,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
