import 'dart:async';

import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';
import 'package:capstone_2026/feature/partner_dashboard/presentation/screen/partner_dashboard_action.dart';
import 'package:capstone_2026/feature/partner_dashboard/presentation/screen/partner_dashboard_event.dart';
import 'package:capstone_2026/feature/partner_dashboard/presentation/screen/partner_dashboard_screen.dart';
import 'package:capstone_2026/feature/partner_dashboard/presentation/screen/partner_dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartnerDashboardScreenRoot extends StatefulWidget {
  final PartnerDashboardViewModel viewModel;

  const PartnerDashboardScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerDashboardScreenRoot> createState() =>
      _PartnerDashboardScreenRootState();
}

class _PartnerDashboardScreenRootState extends State<PartnerDashboardScreenRoot> {
  static const int _partnerStoreTabIndex = 1;
  static const int _partnerReservationsTabIndex = 2;

  StreamSubscription<PartnerDashboardEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    widget.viewModel.fetch();

    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (!mounted) {
        return;
      }

      switch (event) {
        case ShowMessage(:final message, :final variant):
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
        return PartnerDashboardScreen(
          state: widget.viewModel.state,
          onAction: (action) {
            switch (action) {
              case TapEditStore():
                _navigateToPartnerTab(_partnerStoreTabIndex);
                break;
              case TapManageReservations():
                _navigateToPartnerTab(_partnerReservationsTabIndex);
                break;
            }
          },
        );
      },
    );
  }

  void _navigateToPartnerTab(int branchIndex) {
    final navigationShell = StatefulNavigationShell.of(context);
    navigationShell.goBranch(
      branchIndex,
      initialLocation: navigationShell.currentIndex == branchIndex,
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
