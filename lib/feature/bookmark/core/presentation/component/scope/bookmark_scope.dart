import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_screen_root.dart';
import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_view_model.dart';
import 'package:flutter/material.dart';

class BookmarkScope extends StatefulWidget {
  const BookmarkScope({
    required this.viewModel,
    super.key,
  });

  final BookmarkViewModel viewModel;

  @override
  State<BookmarkScope> createState() => _BookmarkScopeState();
}

class _BookmarkScopeState extends State<BookmarkScope> {
  late final BookmarkViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return BookmarkScreenRoot(viewModel: _viewModel);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
