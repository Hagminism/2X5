import 'dart:io';

import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
import 'package:capstone_2026/feature/partner_page/presentation/component/partner_form_text_field.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_action.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_state.dart';
import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
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
        if (state.isLoading || state.isSaving)
          ModalBarrier(
            dismissible: false,
            color: AppColors.black.withValues(alpha: 0.2588),
          ),
        if (state.isLoading || state.isSaving)
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
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
                  onAction(const PartnerSalonManagementAction.tapRetry());
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
        _SectionHeader(title: '예약 슬롯', actionLabel: null, onTap: null),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('30분'),
              selected: state.settings.slotMinutes == 30,
              onSelected: (_) {
                onAction(
                  const PartnerSalonManagementAction.selectSlotMinutes(30),
                );
              },
            ),
            ChoiceChip(
              label: const Text('60분'),
              selected: state.settings.slotMinutes == 60,
              onSelected: (_) {
                onAction(
                  const PartnerSalonManagementAction.selectSlotMinutes(60),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _NavigationCard(
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
        _NavigationCard(
          icon: Icons.spa_rounded,
          title: '시술 관리',
          description: '시술명, 소요 시간, 가격, 안내 문구를 관리합니다.',
          onTap: () {
            onAction(
              const PartnerSalonManagementAction.openServiceManagement(),
            );
          },
        ),
        if (state.saveMessage != null) ...[
          const SizedBox(height: 20),
          Text(state.saveMessage!, style: AppTextStyles.bodySecondary),
        ],
        if (state.isSaving) ...[
          const SizedBox(height: 20),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}

class PartnerSalonDesignerManagementScreen extends StatelessWidget {
  final PartnerSalonManagementState state;
  final void Function(PartnerSalonManagementAction action) onAction;

  const PartnerSalonDesignerManagementScreen({
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
            title: const Text('디자이너 관리'),
            backgroundColor: AppColors.white,
            surfaceTintColor: AppColors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                onAction(const PartnerSalonManagementAction.tapBack());
              },
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.errorMessage != null)
                  _ErrorRetry(
                    message: state.errorMessage!,
                    onAction: onAction,
                  ),
                for (var i = 0; i < state.designers.length; i++) ...[
                  _DesignerEditor(
                    index: i,
                    designer: state.designers[i],
                    localImagePath: i < state.localDesignerImagePaths.length
                        ? state.localDesignerImagePaths[i]
                        : null,
                    onAction: onAction,
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: AppColors.primary,
                      textStyle: AppTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () {
                      onAction(
                        const PartnerSalonManagementAction.tapAddDesigner(),
                      );
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('디자이너 추가'),
                  ),
                ),
                const SizedBox(height: 12),
                Opacity(
                  opacity: state.isSaving ? 0.7 : 1,
                  child: IgnorePointer(
                    ignoring: state.isSaving,
                    child: PrimaryButton(
                      text: state.isSaving ? '저장 중...' : '저장',
                      onTap: () {
                        onAction(
                          const PartnerSalonManagementAction.tapSaveDesigners(),
                        );
                      },
                    ),
                  ),
                ),
                if (state.saveMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(state.saveMessage!, style: AppTextStyles.bodySecondary),
                ],
              ],
            ),
          ),
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
}

class PartnerSalonServiceManagementScreen extends StatelessWidget {
  final PartnerSalonManagementState state;
  final void Function(PartnerSalonManagementAction action) onAction;

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
                onAction(const PartnerSalonManagementAction.tapBack());
              },
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (state.errorMessage != null)
                  _ErrorRetry(
                    message: state.errorMessage!,
                    onAction: onAction,
                  ),
                _SectionHeader(
                  title: '시술',
                  actionLabel: '추가',
                  onTap: () {
                    onAction(
                      const PartnerSalonManagementAction.tapAddService(),
                    );
                  },
                ),
                const SizedBox(height: 10),
                if (state.services.isEmpty)
                  const _EmptyText('등록된 시술이 없습니다.')
                else
                  ...state.services.map(
                    (service) =>
                        _ServiceTile(service: service, onAction: onAction),
                  ),
                const SizedBox(height: 24),
                _SectionHeader(title: '근무표', actionLabel: null, onTap: null),
                const SizedBox(height: 10),
                if (state.selectedDesignerId == null)
                  const _EmptyText('근무표를 설정할 디자이너를 먼저 등록해 주세요.')
                else
                  ...state.schedules.map(
                    (schedule) =>
                        _ScheduleTile(schedule: schedule, onAction: onAction),
                  ),
                if (state.saveMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(state.saveMessage!, style: AppTextStyles.bodySecondary),
                ],
              ],
            ),
          ),
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
}

class _NavigationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(description, style: AppTextStyles.bodySecondary),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final void Function(PartnerSalonManagementAction action) onAction;

  const _ErrorRetry({
    required this.message,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              onAction(const PartnerSalonManagementAction.tapRetry());
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

class _DesignerEditor extends StatelessWidget {
  final int index;
  final SalonDesigner designer;
  final String? localImagePath;
  final void Function(PartnerSalonManagementAction action) onAction;

  const _DesignerEditor({
    required this.index,
    required this.designer,
    required this.localImagePath,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        (localImagePath != null && localImagePath!.isNotEmpty) ||
        designer.imageUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '디자이너 ${index + 1}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  onAction(
                    PartnerSalonManagementAction.tapRemoveDesigner(index),
                  );
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          PartnerFormTextField(
            key: ValueKey('designer-name-$index-${designer.id}'),
            hintText: '디자이너명',
            initialValue: designer.name,
            onChanged: (value) {
              onAction(
                PartnerSalonManagementAction.changeDesignerName(
                  index: index,
                  value: value,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          PartnerFormTextField(
            key: ValueKey('designer-intro-$index-${designer.id}'),
            hintText: '소개 문구(선택)',
            initialValue: designer.introduction,
            onChanged: (value) {
              onAction(
                PartnerSalonManagementAction.changeDesignerIntroduction(
                  index: index,
                  value: value,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: AppColors.primary,
              ),
              onPressed: () {
                onAction(
                  PartnerSalonManagementAction.tapPickDesignerImage(index),
                );
              },
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                designer.imageUrl.isEmpty ? '디자이너 이미지 선택' : '이미지 변경',
              ),
            ),
          ),
          if (hasImage) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: localImagePath != null && localImagePath!.isNotEmpty
                      ? Image.file(
                          File(localImagePath!),
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          designer.imageUrl,
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            onAction(
                              PartnerSalonManagementAction.removeDesignerImage(
                                index,
                              ),
                            );
                          },
                          child: const Text('이미지 삭제'),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildActiveToggle(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  localImagePath != null && localImagePath!.isNotEmpty
                      ? '선택 완료 (저장 시 업로드)'
                      : '업로드 완료',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          if (!hasImage) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: _buildActiveToggle(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: designer.isActive,
          activeThumbColor: AppColors.primary,
          onChanged: (value) {
            onAction(
              PartnerSalonManagementAction.toggleDesignerActive(
                index: index,
                value: value,
              ),
            );
          },
        ),
        const SizedBox(width: 4),
        Text(
          designer.isActive ? '노출 중' : '숨김',
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
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

class _ServiceTile extends StatelessWidget {
  final SalonService service;
  final void Function(PartnerSalonManagementAction action) onAction;

  const _ServiceTile({
    required this.service,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return _ManagementTile(
      selected: false,
      title: service.name,
      description:
          '${service.durationMinutes}분 · ${service.price}원\n${service.description}',
      trailing: Switch(
        value: service.isActive,
        onChanged: (_) {
          onAction(PartnerSalonManagementAction.tapToggleService(service));
        },
      ),
      onTap: () {
        onAction(PartnerSalonManagementAction.tapEditService(service));
      },
      onEdit: () {
        onAction(PartnerSalonManagementAction.tapEditService(service));
      },
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final SalonDesignerSchedule schedule;
  final void Function(PartnerSalonManagementAction action) onAction;

  const _ScheduleTile({
    required this.schedule,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return _ManagementTile(
      selected: false,
      title: _dayLabel(schedule.dayOfWeek),
      description: schedule.isWorking
          ? '${schedule.startTime} - ${schedule.endTime}'
          : '휴무',
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        onAction(PartnerSalonManagementAction.tapEditSchedule(schedule));
      },
      onEdit: () {
        onAction(PartnerSalonManagementAction.tapEditSchedule(schedule));
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

class _ManagementTile extends StatelessWidget {
  final bool selected;
  final String title;
  final String description;
  final Widget trailing;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _ManagementTile({
    required this.selected,
    required this.title,
    required this.description,
    required this.trailing,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: selected
          ? AppColors.primary.withValues(alpha: 0.08)
          : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded),
            ),
            trailing,
          ],
        ),
      ),
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
