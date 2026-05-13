import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/core/domain/model/salon/salon_service.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_action.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_screen.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class PartnerSalonManagementScreenRoot extends StatefulWidget {
  final PartnerSalonManagementViewModel viewModel;

  const PartnerSalonManagementScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerSalonManagementScreenRoot> createState() =>
      _PartnerSalonManagementScreenRootState();
}

class _PartnerSalonManagementScreenRootState
    extends State<PartnerSalonManagementScreenRoot> {
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
        return PartnerSalonManagementScreen(
          state: widget.viewModel.state,
          onAction: (PartnerSalonManagementAction action) {
            switch (action) {
              case PartnerSalonManagementTapRetry():
              case PartnerSalonManagementSelectSlotMinutes():
                widget.viewModel.onAction(action);
                break;
              case PartnerSalonManagementTapBack():
                context.pop();
                break;
              case PartnerSalonManagementOpenDesignerManagement():
                context.push(
                  '${Routes.partnerStore}/${Routes.partnerSalonManagement}/${Routes.partnerSalonDesigners}',
                );
                break;
              case PartnerSalonManagementOpenServiceManagement():
                context.push(
                  '${Routes.partnerStore}/${Routes.partnerSalonManagement}/${Routes.partnerSalonServices}',
                );
                break;
              case PartnerSalonManagementSelectDesigner():
              case PartnerSalonManagementTapAddDesigner():
              case PartnerSalonManagementTapRemoveDesigner():
              case PartnerSalonManagementChangeDesignerName():
              case PartnerSalonManagementChangeDesignerIntroduction():
              case PartnerSalonManagementRemoveDesignerImage():
              case PartnerSalonManagementToggleDesignerActive():
              case PartnerSalonManagementTapSaveDesigners():
                break;
              case PartnerSalonManagementTapPickDesignerImage():
              case PartnerSalonManagementTapAddService():
              case PartnerSalonManagementTapEditService():
              case PartnerSalonManagementTapToggleService():
              case PartnerSalonManagementTapEditSchedule():
                break;
            }
          },
        );
      },
    );
  }
}

class PartnerSalonDesignerManagementScreenRoot extends StatefulWidget {
  final PartnerSalonManagementViewModel viewModel;

  const PartnerSalonDesignerManagementScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerSalonDesignerManagementScreenRoot> createState() =>
      _PartnerSalonDesignerManagementScreenRootState();
}

class _PartnerSalonDesignerManagementScreenRootState
    extends State<PartnerSalonDesignerManagementScreenRoot> {
  final ImagePicker _imagePicker = ImagePicker();

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
        return PartnerSalonDesignerManagementScreen(
          state: widget.viewModel.state,
          onAction: (PartnerSalonManagementAction action) {
            switch (action) {
              case PartnerSalonManagementTapRetry():
              case PartnerSalonManagementTapAddDesigner():
              case PartnerSalonManagementTapRemoveDesigner():
              case PartnerSalonManagementChangeDesignerName():
              case PartnerSalonManagementChangeDesignerIntroduction():
              case PartnerSalonManagementRemoveDesignerImage():
              case PartnerSalonManagementToggleDesignerActive():
              case PartnerSalonManagementTapSaveDesigners():
                widget.viewModel.onAction(action);
                break;
              case PartnerSalonManagementTapBack():
                context.pop();
                break;
              case PartnerSalonManagementTapPickDesignerImage(:final index):
                _pickDesignerImage(index);
                break;
              case PartnerSalonManagementSelectSlotMinutes():
              case PartnerSalonManagementOpenDesignerManagement():
              case PartnerSalonManagementOpenServiceManagement():
              case PartnerSalonManagementSelectDesigner():
              case PartnerSalonManagementTapAddService():
              case PartnerSalonManagementTapEditService():
              case PartnerSalonManagementTapToggleService():
              case PartnerSalonManagementTapEditSchedule():
                break;
            }
          },
        );
      },
    );
  }

  Future<void> _pickDesignerImage(int index) async {
    final selected = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (selected == null) {
      return;
    }
    await widget.viewModel.updateDesignerImageFromFile(
      index: index,
      filePath: selected.path,
    );
  }
}

class PartnerSalonServiceManagementScreenRoot extends StatefulWidget {
  final PartnerSalonManagementViewModel viewModel;

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
          onAction: (PartnerSalonManagementAction action) {
            switch (action) {
              case PartnerSalonManagementTapRetry():
              case PartnerSalonManagementSelectDesigner():
                widget.viewModel.onAction(action);
                break;
              case PartnerSalonManagementTapBack():
                context.pop();
                break;
              case PartnerSalonManagementTapAddService():
                _openServiceDialog();
                break;
              case PartnerSalonManagementTapEditService(:final service):
                _openServiceDialog(service: service);
                break;
              case PartnerSalonManagementTapToggleService(:final service):
                widget.viewModel.saveService(
                  id: service.id,
                  name: service.name,
                  description: service.description,
                  durationMinutes: service.durationMinutes,
                  price: service.price,
                  isActive: !service.isActive,
                );
                break;
              case PartnerSalonManagementTapEditSchedule(:final schedule):
                _openScheduleDialog(schedule);
                break;
              case PartnerSalonManagementSelectSlotMinutes():
              case PartnerSalonManagementOpenDesignerManagement():
              case PartnerSalonManagementOpenServiceManagement():
              case PartnerSalonManagementTapAddDesigner():
              case PartnerSalonManagementTapRemoveDesigner():
              case PartnerSalonManagementChangeDesignerName():
              case PartnerSalonManagementChangeDesignerIntroduction():
              case PartnerSalonManagementTapPickDesignerImage():
              case PartnerSalonManagementRemoveDesignerImage():
              case PartnerSalonManagementToggleDesignerActive():
              case PartnerSalonManagementTapSaveDesigners():
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
