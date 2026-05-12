import 'dart:async';

import 'package:capstone_2026/feature/studycafe_time_selection/presentation/component/time_selection_usage_option_labels.dart';
import 'package:capstone_2026/feature/studycafe_time_selection/presentation/screen/time_selection_action.dart';
import 'package:capstone_2026/feature/studycafe_time_selection/presentation/screen/time_selection_screen.dart';
import 'package:capstone_2026/feature/studycafe_time_selection/presentation/screen/time_selection_view_model.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TimeSelectionScreenRoot extends StatefulWidget {
  final TimeSelectionViewModel viewModel;
  final String storeId;
  final String seatId;
  final String seatLabel;

  const TimeSelectionScreenRoot({
    super.key,
    required this.viewModel,
    required this.storeId,
    required this.seatId,
    required this.seatLabel,
  });

  @override
  State<TimeSelectionScreenRoot> createState() =>
      _TimeSelectionScreenRootState();
}

class _TimeSelectionScreenRootState extends State<TimeSelectionScreenRoot> {
  @override
  void initState() {
    super.initState();
    unawaited(
      widget.viewModel.startScreen(
        storeId: widget.storeId,
        seatId: widget.seatId,
        seatLabel: widget.seatLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (BuildContext context, Widget? child) {
        return TimeSelectionScreen(
          state: widget.viewModel.state,
          canSubmit: widget.viewModel.canSubmit,
          onAction: (TimeSelectionAction action) {
            switch (action) {
              case TapRetry():
              case TapSelectUsageOption():
                widget.viewModel.onAction(action);
                break;
              case TapBack():
                context.pop();
                break;
              case TapSubmit():
                unawaited(_onTapSubmit(context));
                break;
            }
          },
        );
      },
    );
  }

  Future<void> _onTapSubmit(BuildContext context) async {
    if (!widget.viewModel.canSubmit) {
      return;
    }
    final selected = widget.viewModel.selectedUsageOption();
    if (selected == null) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('예약 확인'),
          content: Text(
            '${widget.viewModel.state.seatLabel}번 좌석, '
            '${timeSelectionUsageOptionTitle(selected)} '
            '(${timeSelectionUsageOptionPriceLabel(selected)})으로\n'
            '이용을 시작할까요?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                '확인',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final bool ok = await widget.viewModel.submitUsage();
    if (!context.mounted) {
      return;
    }

    if (!ok) {
      final String? message = widget.viewModel.state.submitError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? '예약에 실패했습니다.')),
      );
      return;
    }

    final int? hours = selected.durationMinutes % 60 == 0
        ? selected.durationMinutes ~/ 60
        : null;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('이용 시작'),
          content: Text(
            hours != null
                ? '${widget.viewModel.state.seatLabel}번 좌석을 '
                    '$hours시간 이용합니다.'
                : '${widget.viewModel.state.seatLabel}번 좌석을 '
                    '${selected.durationMinutes}분 이용합니다.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go('/');
              },
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
