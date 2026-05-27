import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_screen.dart';
import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_view_model.dart';
import 'package:flutter/material.dart';

class BookmarkScreenRoot extends StatefulWidget {
  const BookmarkScreenRoot({
    required this.viewModel,
    super.key,
  });

  final BookmarkViewModel viewModel;

  @override
  State<BookmarkScreenRoot> createState() => _BookmarkScreenRootState();
}

class _BookmarkScreenRootState extends State<BookmarkScreenRoot> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return BookmarkScreen(viewModel: widget.viewModel);
      },
    );
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }
}
