import 'dart:async';

import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/map_store_information/studycafe_pass_selection/presentation/component/map_studycafe_pass_selection_usage_option_list.dart';
import 'package:capstone_2026/feature/map_store_information/studycafe_pass_selection/presentation/screen/map_studycafe_pass_selection_action.dart';
import 'package:capstone_2026/feature/map_store_information/studycafe_pass_selection/presentation/screen/map_studycafe_pass_selection_screen.dart';
import 'package:capstone_2026/feature/map_store_information/studycafe_pass_selection/presentation/screen/map_studycafe_pass_selection_view_model.dart';
import 'package:capstone_2026/core/domain/util/studycafe_usage_success_message.dart';
import 'package:capstone_2026/core/presentation/component/dialog/app_confirm_dialog.dart';
import 'package:capstone_2026/core/presentation/component/dialog/app_success_dialog.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MapStudycafePassSelectionScreenRoot extends StatefulWidget {
  final MapStudycafePassSelectionViewModel viewModel;
  final Map<String, String> seatInfo;

  const MapStudycafePassSelectionScreenRoot({
    super.key,
    required this.viewModel,
    required this.seatInfo,
  });

  @override
  State<MapStudycafePassSelectionScreenRoot> createState() =>
      _MapStudycafePassSelectionScreenRootState();
}

class _MapStudycafePassSelectionScreenRootState
    extends State<MapStudycafePassSelectionScreenRoot> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize(
      storeId: widget.seatInfo['storeId'] ?? '',
      seatId: widget.seatInfo['seatId'] ?? '',
      seatLabel: widget.seatInfo['seatLabel'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (BuildContext context, Widget? child) {
        return MapStudycafePassSelectionScreen(
          state: widget.viewModel.state,
          canSubmit: widget.viewModel.canSubmit,
          onAction: (MapStudycafePassSelectionAction action) {
            switch (action) {
              case MapStudycafePassTapRetry():
              case MapStudycafePassTapSelectUsageOption():
                widget.viewModel.onAction(action);
                break;
              case MapStudycafePassTapBack():
                context.pop();
                break;
              case MapStudycafePassTapSubmit():
                unawaited(_onTapSubmit());
                break;
            }
          },
        );
      },
    );
  }

  Future<void> _onTapSubmit() async {
    if (!mounted) {
      return;
    }

    if (!widget.viewModel.canSubmit) {
      return;
    }
    final selected = widget.viewModel.selectedUsageOption();
    if (selected == null) {
      return;
    }

    final bool confirmed = await showAppConfirmDialog(
      context,
      title: '이용 확인',
      message:
          '${widget.viewModel.state.seatLabel}번 좌석, '
          '${mapStudycafePassUsageOptionTitle(selected)} '
          '(${mapStudycafePassUsageOptionPriceLabel(selected)})으로\n'
          '이용을 시작할까요?',
    );

    if (!confirmed || !mounted) {
      return;
    }

    final bool ok = await widget.viewModel.submitUsage();
    if (!mounted) {
      return;
    }

    if (!ok) {
      final String? message = widget.viewModel.state.submitError;
      AppSnackBar.showError(context, message ?? '예약에 실패했습니다.');
      return;
    }

    await showAppSuccessDialog(
      context,
      title: '이용이 시작되었습니다',
      subtitle: '아래 내용으로 이용이 시작되었어요.',
      message: studycafeUsageSuccessMessage(
        seatLabel: widget.viewModel.state.seatLabel,
        selected: selected,
      ),
      onConfirm: () {
        final String? storeId = widget.seatInfo['storeId'];
        if (storeId == null || storeId.isEmpty) {
          return;
        }
        context.go('${Routes.map}/map-store-information/$storeId');
      },
    );
  }
}
