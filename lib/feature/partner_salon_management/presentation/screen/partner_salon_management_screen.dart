import 'package:capstone_2026/feature/partner_salon_management/presentation/component/partner_salon_management_navigation_card.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_action.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';

class PartnerSalonManagementScreen extends StatelessWidget {
  final PartnerSalonManagementState state;
  final void Function(PartnerSalonManagementAction action) onAction;

  const PartnerSalonManagementScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            title: const Text('미용실 관리'),
            backgroundColor: AppColors.white,
            surfaceTintColor: AppColors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                onAction(const PartnerSalonManagementAction.tapBack());
              },
            ),
          ),
          body: SafeArea(child: _buildBody()),
        ),
        if (state.isLoading) ...[
          ModalBarrier(
            dismissible: false,
            color: AppColors.black.withValues(alpha: 0.2588),
          ),
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PartnerSalonManagementNavigationCard(
          icon: Icons.person_rounded,
          title: '디자이너 관리',
          description: '디자이너 소개, 사진, 노출 여부를 관리합니다.',
          onTap: () {
            onAction(
              const PartnerSalonManagementAction.openDesignerManagement(),
            );
          },
        ),
        const SizedBox(height: 12),
        PartnerSalonManagementNavigationCard(
          icon: Icons.calendar_month_rounded,
          title: '근무 편성',
          description: '디자이너별 근무일과 근무 시간을 관리합니다.',
          onTap: () {
            onAction(
              const PartnerSalonManagementAction.openScheduleManagement(),
            );
          },
        ),
        const SizedBox(height: 12),
        PartnerSalonManagementNavigationCard(
          icon: Icons.spa_rounded,
          title: '시술 관리',
          description: '각 시술의 세부 정보를 관리합니다.',
          onTap: () {
            onAction(
              const PartnerSalonManagementAction.openServiceManagement(),
            );
          },
        ),
      ],
    );
  }
}
