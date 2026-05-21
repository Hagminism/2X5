import 'package:capstone_2026/feature/partner_salon_management/presentation/component/partner_salon_management_error_view.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/component/partner_salon_management_section_header.dart';
import 'package:capstone_2026/feature/partner_salon_schedule_management/presentation/component/partner_salon_designer_selector.dart';
import 'package:capstone_2026/feature/partner_salon_schedule_management/presentation/component/partner_salon_schedule_empty_text.dart';
import 'package:capstone_2026/feature/partner_salon_schedule_management/presentation/component/partner_salon_schedule_tile.dart';
import 'package:capstone_2026/feature/partner_salon_schedule_management/presentation/screen/partner_salon_schedule_management_action.dart';
import 'package:capstone_2026/feature/partner_salon_schedule_management/presentation/screen/partner_salon_schedule_management_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerSalonScheduleManagementScreen extends StatelessWidget {
  final PartnerSalonScheduleManagementState state;
  final void Function(PartnerSalonScheduleManagementAction action) onAction;

  const PartnerSalonScheduleManagementScreen({
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
            title: const Text('근무 편성'),
            backgroundColor: AppColors.white,
            surfaceTintColor: AppColors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                onAction(const PartnerSalonScheduleManagementAction.tapBack());
              },
            ),
          ),
          body: SafeArea(child: _buildBody()),
        ),
        if (state.isLoading || state.isSaving)
          ModalBarrier(
            dismissible: false,
            color: AppColors.black.withValues(alpha: 0.2588),
          ),
        if (state.isLoading || state.isSaving)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
      ],
    );
  }

  Widget _buildBody() {
    final errorMessage = state.errorMessage;
    if (errorMessage != null) {
      return PartnerSalonManagementErrorView(
        message: errorMessage,
        onRetry: () {
          onAction(const PartnerSalonScheduleManagementAction.tapRetry());
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const PartnerSalonManagementSectionHeader(
          title: '디자이너',
          actionLabel: null,
          onTap: null,
        ),
        const SizedBox(height: 10),
        if (state.designers.isEmpty)
          const PartnerSalonScheduleEmptyText(
            message: '근무표를 설정할 디자이너를 먼저 등록해 주세요.',
          )
        else
          PartnerSalonDesignerSelector(
            designers: state.designers,
            selectedDesignerId: state.selectedDesignerId,
            onSelected: (designerId) {
              onAction(
                PartnerSalonScheduleManagementAction.selectDesigner(designerId),
              );
            },
          ),
        const SizedBox(height: 24),
        const PartnerSalonManagementSectionHeader(
          title: '근무표',
          actionLabel: null,
          onTap: null,
        ),
        const SizedBox(height: 10),
        if (state.selectedDesignerId == null)
          const PartnerSalonScheduleEmptyText(
            message: '근무표를 설정할 디자이너를 선택해 주세요.',
          )
        else
          ...state.schedules.map(
            (schedule) => PartnerSalonScheduleTile(
              schedule: schedule,
              onAction: onAction,
            ),
          ),
        if (state.saveMessage != null) ...[
          const SizedBox(height: 20),
          Text(state.saveMessage!, style: AppTextStyles.bodySecondary),
        ],
      ],
    );
  }
}
