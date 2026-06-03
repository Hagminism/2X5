import 'package:capstone_2026/core/presentation/component/dialog/app_info_dialog.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';
import 'package:capstone_2026/feature/my_page/stamp_history/presentation/screen/stamp_history_screen.dart';
import 'package:capstone_2026/feature/my_page/stamp_history/presentation/screen/stamp_history_view_model.dart';
import 'package:capstone_2026/feature/stamp/domain/model/store_stamp_status.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StampHistoryScreenRoot extends StatefulWidget {
  const StampHistoryScreenRoot({
    required this.viewModel,
    super.key,
  });

  final StampHistoryViewModel viewModel;

  @override
  State<StampHistoryScreenRoot> createState() => _StampHistoryScreenRootState();
}

class _StampHistoryScreenRootState extends State<StampHistoryScreenRoot> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.fetchStamps();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return StampHistoryScreen(
          state: widget.viewModel.state,
          onTapWriteReview: (status) {
            context.pushNamed(
              'information',
              pathParameters: {'storeId': status.storeId},
            );
          },
          onTapClaimReward: _claimReward,
        );
      },
    );
  }

  Future<void> _claimReward(StoreStampStatus status) async {
    try {
      final updatedStatus = await widget.viewModel.claimReward(status);
      if (!mounted) {
        return;
      }
      await _showClaimRewardDialog(
        beforeClaim: status,
        afterClaim: updatedStatus,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppSnackBar.showError(context, '보상 수령 처리 중 오류가 발생했습니다.');
    }
  }

  Future<void> _showClaimRewardDialog({
    required StoreStampStatus beforeClaim,
    required StoreStampStatus afterClaim,
  }) async {
    await showAppInfoDialog(
      context,
      title: '보상 수령 완료',
      message:
          '${beforeClaim.storeName} 보상을 수령했습니다.\n\n'
          '${beforeClaim.rewardTitle}\n'
          '${beforeClaim.rewardDescription}\n\n'
          '남은 스탬프는 ${afterClaim.progressLabel}입니다.',
    );
  }
}
