import 'dart:async';

import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_action.dart';
import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_event.dart';
import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_screen.dart';
import 'package:capstone_2026/feature/bookmark/presentation/screen/bookmark_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

class BookmarkScreenRoot extends StatefulWidget {
  final BookmarkViewModel viewModel;

  const BookmarkScreenRoot({
    required this.viewModel,
    super.key,
  });

  @override
  State<BookmarkScreenRoot> createState() => _BookmarkScreenRootState();
}

class _BookmarkScreenRootState extends State<BookmarkScreenRoot> {
  StreamSubscription<BookmarkEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (!mounted) {
        return;
      }

      switch (event) {
        case ShowSnackBar(:final message, :final variant):
          AppSnackBar.show(context, message, variant: variant);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return BookmarkScreen(
          state: widget.viewModel.state,
          onAction: (action) {
            switch (action) {
              case RefreshBookmarks():
              case RetryLoadBookmarks():
              case SelectBookmarkCategory():
              case RemoveBookmark():
                widget.viewModel.onAction(action);
                break;
              case TapBookmarkStore(:final storeId):
                context.pushNamed(
                  Routes.bookmarkInformationName,
                  pathParameters: {
                    'storeId': storeId,
                  },
                );
                break;
              case TapExploreStores():
                context.go(Routes.home);
                break;
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
