import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
import 'package:capstone_2026/feature/partner_salon_service_management/presentation/component/partner_salon_management_tile.dart';
import 'package:capstone_2026/feature/partner_salon_service_management/presentation/screen/partner_salon_service_management_action.dart';
import 'package:capstone_2026/feature/partner_salon_service_management/presentation/screen/partner_salon_service_management_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerSalonServiceManagementScreen extends StatelessWidget {
  final PartnerSalonServiceManagementState state;
  final void Function(PartnerSalonServiceManagementAction action) onAction;

  const PartnerSalonServiceManagementScreen({
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
            title: const Text('시술 관리'),
            backgroundColor: AppColors.white,
            surfaceTintColor: AppColors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                onAction(const PartnerSalonServiceManagementAction.tapBack());
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  onAction(
                    const PartnerSalonServiceManagementAction.tapRetry(),
                  );
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(
          title: '시술',
          actionLabel: '추가',
          onTap: () {
            onAction(const PartnerSalonServiceManagementAction.tapAddService());
          },
        ),
        const SizedBox(height: 10),
        if (state.services.isEmpty)
          const _EmptyText('등록된 시술이 없습니다.')
        else
          ...state.services.map(
            (service) => _ServiceTile(service: service, onAction: onAction),
          ),
        const SizedBox(height: 24),
        _SectionHeader(title: '근무표', actionLabel: null, onTap: null),
        const SizedBox(height: 10),
        if (state.designers.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.designers
                .map(
                  (designer) => ChoiceChip(
                    label: Text(designer.name),
                    selected: state.selectedDesignerId == designer.id,
                    onSelected: (_) {
                      onAction(
                        PartnerSalonServiceManagementAction.selectDesigner(
                          designer.id,
                        ),
                      );
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
        ],
        if (state.selectedDesignerId == null)
          const _EmptyText('근무표를 설정할 디자이너를 먼저 등록해 주세요.')
        else
          ...state.schedules.map(
            (schedule) => _ScheduleTile(schedule: schedule, onAction: onAction),
          ),
        if (state.saveMessage != null) ...[
          const SizedBox(height: 20),
          Text(state.saveMessage!, style: AppTextStyles.bodySecondary),
        ],
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final SalonService service;
  final void Function(PartnerSalonServiceManagementAction action) onAction;

  const _ServiceTile({
    required this.service,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return PartnerSalonManagementTile(
      title: service.name,
      description:
          '${service.durationMinutes}분 · ${service.price}원\n${service.description}',
      trailing: Switch(
        value: service.isActive,
        onChanged: (_) {
          onAction(
            PartnerSalonServiceManagementAction.tapToggleService(service),
          );
        },
      ),
      onTap: () {
        onAction(PartnerSalonServiceManagementAction.tapEditService(service));
      },
      onEdit: () {
        onAction(PartnerSalonServiceManagementAction.tapEditService(service));
      },
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final SalonDesignerSchedule schedule;
  final void Function(PartnerSalonServiceManagementAction action) onAction;

  const _ScheduleTile({
    required this.schedule,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return PartnerSalonManagementTile(
      title: _dayLabel(schedule.dayOfWeek),
      description: schedule.isWorking
          ? '${schedule.startTime} - ${schedule.endTime}'
          : '휴무',
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        onAction(PartnerSalonServiceManagementAction.tapEditSchedule(schedule));
      },
      onEdit: () {
        onAction(PartnerSalonServiceManagementAction.tapEditSchedule(schedule));
      },
    );
  }

  String _dayLabel(int dayOfWeek) {
    const labels = ['일', '월', '화', '수', '목', '금', '토'];
    if (dayOfWeek < 0 || dayOfWeek >= labels.length) {
      return '요일';
    }
    return '${labels[dayOfWeek]}요일';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (actionLabel != null && onTap != null)
          TextButton(onPressed: onTap, child: Text(actionLabel!)),
      ],
    );
  }
}

class _EmptyText extends StatelessWidget {
  final String message;

  const _EmptyText(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: AppTextStyles.bodySecondary)),
        ],
      ),
    );
  }
}
