import 'package:capstone_2026/feature/my_page/review_history/presentation/screen/review_history_screen.dart';
import 'package:capstone_2026/feature/my_page/review_history/presentation/screen/review_history_view_model.dart';
import 'package:capstone_2026/feature/store_detail/domain/model/internal_review.dart';
import 'package:capstone_2026/feature/store_detail/presentation/component/review_write_bottom_sheet.dart';
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
        return ReviewHistoryScreen(
          state: widget.viewModel.state,
          onEditReview: _handleEditReview,
          onDeleteReview: _handleDeleteReview,
        );
      },
    );
  }

  Future<void> _handleEditReview(
    InternalReview review,
    ReviewWriteResult result,
  ) async {
    await widget.viewModel.updateReview(
      currentReview: review,
      result: result,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('리뷰를 수정했습니다.')),
      );
  }

  Future<void> _handleDeleteReview(InternalReview review) async {
    await widget.viewModel.deleteReview(review: review);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('리뷰를 삭제했습니다.')),
      );
  }
}
