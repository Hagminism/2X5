import 'package:flutter/material.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_view_model.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_screen.dart';

class StoreDetailScreenRoot extends StatelessWidget {
  final StoreDetailViewModel viewModel;
  final String storeId;

  const StoreDetailScreenRoot({
    required this.viewModel,
    required this.storeId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StoreDetailScreen(
      state: viewModel.state,
      onAction: (action) => viewModel.onAction(action),

      onSubmitReview: (result) async {

        return;
      },
    );
  }
}