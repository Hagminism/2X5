import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
import 'package:capstone_2026/feature/partner_salon_service_management/presentation/screen/partner_salon_service_management_action.dart';
import 'package:capstone_2026/feature/partner_salon_service_management/presentation/screen/partner_salon_service_management_screen.dart';
import 'package:capstone_2026/feature/partner_salon_service_management/presentation/screen/partner_salon_service_management_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartnerSalonServiceManagementScreenRoot extends StatefulWidget {
  final PartnerSalonServiceManagementViewModel viewModel;

  const PartnerSalonServiceManagementScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerSalonServiceManagementScreenRoot> createState() =>
      _PartnerSalonServiceManagementScreenRootState();
}

class _PartnerSalonServiceManagementScreenRootState
    extends State<PartnerSalonServiceManagementScreenRoot> {
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
        return PartnerSalonServiceManagementScreen(
          state: widget.viewModel.state,
          onAction: (PartnerSalonServiceManagementAction action) {
            switch (action) {
              case PartnerSalonServiceManagementTapRetry():
              case PartnerSalonServiceManagementSelectDesigner():
                widget.viewModel.onAction(action);
                break;
              case PartnerSalonServiceManagementTapBack():
                context.pop();
                break;
              case PartnerSalonServiceManagementTapAddService():
                _openServiceDialog();
                break;
              case PartnerSalonServiceManagementTapEditService(:final service):
                _openServiceDialog(service: service);
                break;
              case PartnerSalonServiceManagementTapToggleService(
                :final service,
              ):
                widget.viewModel.saveService(
                  id: service.id,
                  name: service.name,
                  description: service.description,
                  durationMinutes: service.durationMinutes,
                  price: service.price,
                  isActive: !service.isActive,
                );
                break;
              case PartnerSalonServiceManagementTapEditSchedule(
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

  Future<void> _openServiceDialog({SalonService? service}) async {
    final nameController = TextEditingController(text: service?.name ?? '');
    final descriptionController = TextEditingController(
      text: service?.description ?? '',
    );
    final durationController = TextEditingController(
      text: '${service?.durationMinutes ?? 60}',
    );
    final priceController = TextEditingController(
      text: '${service?.price ?? 0}',
    );
    final result = await showDialog<_ServiceInput>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(service == null ? '시술 추가' : '시술 수정'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '시술명'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: '설명/주의사항'),
                ),
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '소요 시간(분)'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '가격'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  _ServiceInput(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    durationMinutes: int.tryParse(durationController.text) ?? 0,
                    price: int.tryParse(priceController.text) ?? 0,
                  ),
                );
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
    if (result == null || result.name.isEmpty || result.durationMinutes <= 0) {
      return;
    }
    await widget.viewModel.saveService(
      id: service?.id ?? '',
      name: result.name,
      description: result.description,
      durationMinutes: result.durationMinutes,
      price: result.price,
      isActive: service?.isActive ?? true,
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

class _ServiceInput {
  final String name;
  final String description;
  final int durationMinutes;
  final int price;

  const _ServiceInput({
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.price,
  });
}
