import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/feature/partner_salon_schedule_management/presentation/screen/partner_salon_schedule_management_action.dart';
import 'package:capstone_2026/feature/partner_salon_schedule_management/presentation/screen/partner_salon_schedule_management_screen.dart';
import 'package:capstone_2026/feature/partner_salon_schedule_management/presentation/screen/partner_salon_schedule_management_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartnerSalonScheduleManagementScreenRoot extends StatefulWidget {
  final PartnerSalonScheduleManagementViewModel viewModel;

  const PartnerSalonScheduleManagementScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerSalonScheduleManagementScreenRoot> createState() =>
      _PartnerSalonScheduleManagementScreenRootState();
}

class _PartnerSalonScheduleManagementScreenRootState
    extends State<PartnerSalonScheduleManagementScreenRoot> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (BuildContext context, Widget? child) {
        return PartnerSalonScheduleManagementScreen(
          state: widget.viewModel.state,
          onAction: (PartnerSalonScheduleManagementAction action) {
            switch (action) {
              case PartnerSalonScheduleManagementTapRetry():
              case PartnerSalonScheduleManagementSelectDesigner():
                widget.viewModel.onAction(action);
                break;
              case PartnerSalonScheduleManagementTapBack():
                context.pop();
                break;
              case PartnerSalonScheduleManagementTapEditSchedule(
                :final schedule,
              ):
                _openScheduleDialog(schedule);
                break;
            }
          },
        );
      },
    );
  }

  Future<void> _openScheduleDialog(SalonDesignerSchedule schedule) async {
    final startController = TextEditingController(text: schedule.startTime);
    final endController = TextEditingController(text: schedule.endTime);
    bool isWorking = schedule.isWorking;
    final result = await showDialog<SalonDesignerSchedule>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('근무 시간 수정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('근무일'),
                    value: isWorking,
                    onChanged: (value) {
                      setDialogState(() {
                        isWorking = value;
                      });
                    },
                  ),
                  TextField(
                    controller: startController,
                    decoration: const InputDecoration(
                      labelText: '시작 시간',
                      hintText: '10:00',
                    ),
                  ),
                  TextField(
                    controller: endController,
                    decoration: const InputDecoration(
                      labelText: '종료 시간',
                      hintText: '19:00',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(
                      schedule.copyWith(
                        isWorking: isWorking,
                        startTime: startController.text.trim(),
                        endTime: endController.text.trim(),
                      ),
                    );
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
    if (result == null) {
      return;
    }
    await widget.viewModel.saveSchedule(result);
  }
}
