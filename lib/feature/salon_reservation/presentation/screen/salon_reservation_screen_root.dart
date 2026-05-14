import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_action.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_screen.dart';
import 'package:capstone_2026/feature/salon_reservation/presentation/screen/salon_reservation_view_model.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SalonReservationScreenRoot extends StatefulWidget {
  final SalonReservationViewModel viewModel;
  final String storeId;
  final String? initialDesignerId;

  const SalonReservationScreenRoot({
    super.key,
    required this.viewModel,
    required this.storeId,
    this.initialDesignerId,
  });

  @override
  State<SalonReservationScreenRoot> createState() =>
      _SalonReservationScreenRootState();
}

class _SalonReservationScreenRootState
    extends State<SalonReservationScreenRoot> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize(
      widget.storeId,
      initialDesignerId: widget.initialDesignerId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (BuildContext context, Widget? child) {
        return SalonReservationScreen(
          state: widget.viewModel.state,
          canSubmit: widget.viewModel.canSubmit,
          onAction: (SalonReservationAction action) {
            switch (action) {
              case SalonReservationTapRetry():
              case SalonReservationSelectDesigner():
              case SalonReservationSelectService():
              case SalonReservationSelectDate():
              case SalonReservationSelectSlot():
                widget.viewModel.onAction(action);
                break;
              case SalonReservationTapBack():
                context.pop();
                break;
              case SalonReservationTapSubmit():
                _onTapSubmit();
                break;
            }
          },
        );
      },
    );
  }

  Future<void> _onTapSubmit() async {
    if (!widget.viewModel.canSubmit || !mounted) {
      return;
    }

    final designer = widget.viewModel.selectedDesigner();
    final service = widget.viewModel.selectedService();
    final startAt = widget.viewModel.state.selectedStartAt;
    if (designer == null || service == null || startAt == null) {
      return;
    }

    final dateLabel = DateFormat('M월 d일 HH:mm', 'ko_KR').format(startAt);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('예약 확인'),
          content: Text(
            '${designer.name} 디자이너\n'
            '${service.name}\n'
            '$dateLabel 예약을 진행할까요?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                '예약',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final ok = await widget.viewModel.submitReservation();
    if (!mounted) {
      return;
    }
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.state.submitError ?? '예약에 실패했습니다.'),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('예약 완료'),
          content: const Text('미용실 예약이 완료되었습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                '확인',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}
