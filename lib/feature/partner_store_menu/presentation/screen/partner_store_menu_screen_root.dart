import 'dart:async';

import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_action.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_event.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_screen.dart';
import 'package:capstone_2026/feature/partner_store_menu/presentation/screen/partner_store_menu_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartnerStoreMenuScreenRoot extends StatefulWidget {
  final PartnerStoreMenuViewModel viewModel;

  const PartnerStoreMenuScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerStoreMenuScreenRoot> createState() =>
      _PartnerStoreMenuScreenRootState();
}

class _PartnerStoreMenuScreenRootState extends State<PartnerStoreMenuScreenRoot> {
  StreamSubscription<PartnerStoreMenuEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (!mounted) return;
      switch (event) {
        case ShowMessage():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(event.message)),
          );
          break;
        case Pop():
          context.pop();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return PartnerStoreMenuScreen(
          state: widget.viewModel.state,
          onAction: (action) {
            switch (action) {
              case AddMenu():
              case RemoveMenu():
              case ChangeMenuName():
              case ChangeMenuPrice():
              case ChangeMenuDescription():
              case ChangeMenuImageUrl():
              case ToggleMenuAvailable():
              case TapSave():
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
