import 'package:capstone_2026/feature/my_page/review_history/presentation/screen/review_history_screen.dart';
import 'package:capstone_2026/feature/my_page/review_history/presentation/screen/review_history_view_model.dart';
import 'package:flutter/material.dart';

class ReviewHistoryScreenRoot extends StatefulWidget {
  const ReviewHistoryScreenRoot({
    required this.viewModel,
    super.key,
  });

  final ReviewHistoryViewModel viewModel;

  @override
  State<ReviewHistoryScreenRoot> createState() =>
      _ReviewHistoryScreenRootState();
}

class _ReviewHistoryScreenRootState extends State<ReviewHistoryScreenRoot> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.fetchReviews();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return ReviewHistoryScreen(state: widget.viewModel.state);
      },
    );
  }
}
