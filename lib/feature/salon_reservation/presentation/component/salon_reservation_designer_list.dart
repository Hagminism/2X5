import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/presentation/component/network/app_network_image.dart';
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
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 160,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.05)
                : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: designer.imageUrl.isEmpty
                        ? ColoredBox(
                            color: AppColors.surfaceMuted,
                            child: const Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                              size: 28,
                            ),
                          )
                        : AppNetworkImage(
                            designer.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => ColoredBox(
                              color: AppColors.surfaceMuted,
                              child: const Icon(
                                Icons.person,
                                color: AppColors.textSecondary,
                                size: 28,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                designer.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                designer.introduction.isEmpty
                    ? '헤어 디자이너'
                    : designer.introduction,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
