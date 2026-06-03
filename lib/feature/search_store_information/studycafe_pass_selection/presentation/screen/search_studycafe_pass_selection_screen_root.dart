import 'dart:async';

import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/search_store_information/studycafe_pass_selection/presentation/component/search_studycafe_pass_selection_usage_option_list.dart';
import 'package:capstone_2026/feature/search_store_information/studycafe_pass_selection/presentation/screen/search_studycafe_pass_selection_action.dart';
import 'package:capstone_2026/feature/search_store_information/studycafe_pass_selection/presentation/screen/search_studycafe_pass_selection_screen.dart';
import 'package:capstone_2026/feature/search_store_information/studycafe_pass_selection/presentation/screen/search_studycafe_pass_selection_view_model.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

class SearchStudycafePassSelectionScreenRoot extends StatefulWidget {
  final SearchStudycafePassSelectionViewModel viewModel;
  final Map<String, String> seatInfo;

  const SearchStudycafePassSelectionScreenRoot({
    super.key,
    required this.viewModel,
    required this.seatInfo,
  });

  @override
  State<SearchStudycafePassSelectionScreenRoot> createState() =>
      _SearchStudycafePassSelectionScreenRootState();
}

class _SearchStudycafePassSelectionScreenRootState
    extends State<SearchStudycafePassSelectionScreenRoot> {
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
        return SearchStudycafePassSelectionScreen(
          state: widget.viewModel.state,
          canSubmit: widget.viewModel.canSubmit,
          onAction: (SearchStudycafePassSelectionAction action) {
            switch (action) {
              case SearchStudycafePassTapRetry():
              case SearchStudycafePassTapSelectUsageOption():
                widget.viewModel.onAction(action);
                break;
              case SearchStudycafePassTapBack():
                context.pop();
                break;
              case SearchStudycafePassTapSubmit():
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

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('예약 확인'),
          content: Text(
            '${widget.viewModel.state.seatLabel}번 좌석, '
            '${searchStudycafePassUsageOptionTitle(selected)} '
            '(${searchStudycafePassUsageOptionPriceLabel(selected)})으로\n'
            '이용을 시작할까요?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                '확인',
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

    final bool ok = await widget.viewModel.submitUsage();
    if (!mounted) {
      return;
    }

    if (!ok) {
      final String? message = widget.viewModel.state.submitError;
      AppSnackBar.showError(context, message ?? '예약에 실패했습니다.');
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
                final String? storeId = widget.seatInfo['storeId'];
                if (storeId == null || storeId.isEmpty) {
                  return;
                }
                context.go(
                  '${Routes.map}/${Routes.search}/search-store-information/$storeId',
                );
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
