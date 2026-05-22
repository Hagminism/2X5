import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_screen.dart';
import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  static const int _bookmarkShellIndex = 2;

  int? _lastShellIndex;

  @override
  void initState() {
    super.initState();
    widget.viewModel.loadBookmarks(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final shellIndex = StatefulNavigationShell.maybeOf(context)?.currentIndex;
    if (shellIndex == _bookmarkShellIndex &&
        _lastShellIndex != _bookmarkShellIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        widget.viewModel.loadBookmarks(force: true);
      });
    }
    _lastShellIndex = shellIndex;

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