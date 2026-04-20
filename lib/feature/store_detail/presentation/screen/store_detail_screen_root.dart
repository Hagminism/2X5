import 'dart:async';

import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_action.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_event.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_screen.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreDetailScreenRoot extends StatefulWidget {
  final String storeId;
  final StoreDetailViewModel viewModel;

  const StoreDetailScreenRoot({
    super.key,
    required this.storeId,
    required this.viewModel,
  });

  @override
  State<StoreDetailScreenRoot> createState() => _StoreDetailScreenRootState();
}

class _StoreDetailScreenRootState extends State<StoreDetailScreenRoot> {
  StreamSubscription<StoreDetailEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    if (_eventSubscription != null) _eventSubscription?.cancel();

    widget.viewModel.initialize(widget.storeId);

    _eventSubscription = widget.viewModel.eventStream.listen((event) async {
      if (mounted) {
        switch (event) {
          case ShowMessage():
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(event.message)));
            break;
          case OpenNaverReview():
            try {
              if (event.appUri != null && await canLaunchUrl(Uri.parse('nmap://'))) {
                await launchUrl(event.appUri!, mode: LaunchMode.externalApplication);
              } else {
                await launchUrl(event.webUri, mode: LaunchMode.externalApplication);
              }
            } catch (_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('외부 링크를 열 수 없습니다.')));
            }
            break;
          case OpenGoogleMap():
            try {
              await launchUrl(event.webUri, mode: LaunchMode.externalApplication);
            } catch (_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('외부 링크를 열 수 없습니다.')));
            }
            break;
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant StoreDetailScreenRoot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storeId != widget.storeId) {
      widget.viewModel.initialize(widget.storeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return StoreDetailScreen(
          state: widget.viewModel.state,
          onAction: (action) {
            switch (action) {
              case TapBack():
                context.pop();
                break;
              case TapHome():
                context.go(Routes.home);
                break;
              case TapSearch():
              case TapBookmark():
              case TapShare():
              case TapCall():
              case TapReserve():
              case TapNaverReviewButton():
              case TapGoogleReviewButton():
              case MoveTab():
                widget.viewModel.onAction(action);
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
