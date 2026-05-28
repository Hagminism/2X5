import 'dart:async';

import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/address_search/domain/model/address_search_result.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_action.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_event.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_screen.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartnerStoreManagementScreenRoot extends StatefulWidget {
  final PartnerStoreManagementViewModel viewModel;

  const PartnerStoreManagementScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerStoreManagementScreenRoot> createState() =>
      _PartnerStoreManagementScreenRootState();
}

class _PartnerStoreManagementScreenRootState
    extends State<PartnerStoreManagementScreenRoot> {
  StreamSubscription<PartnerStoreManagementEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    widget.viewModel.initialize();

    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (!mounted) return;

      switch (event) {
        case ShowMessage():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(event.message),
              duration: const Duration(milliseconds: 1400),
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;
        case OpenAddressSearch():
          _openAddressSearch();
          break;
        case OpenMenuManager():
          context.push('${Routes.partnerStore}/${Routes.partnerStoreMenus}');
          break;
        case OpenLayoutManager():
          context.push('${Routes.partnerStore}/${Routes.partnerStoreLayout}');
          break;
        case OpenSeatLayoutManager():
          context.push(
            '${Routes.partnerStore}/${Routes.partnerStudyCafeLayout}',
          );
          break;
        case OpenStudyCafeUsageOptionManager():
          context.push(
            '${Routes.partnerStore}/${Routes.partnerStudyCafeUsageOptions}',
          );
          break;
        case OpenSalonManager():
          context.push(
            '${Routes.partnerStore}/${Routes.partnerSalonManagement}',
          );
          break;
        case OpenImageManager():
          context.push('${Routes.partnerStore}/${Routes.partnerStoreImages}');
          break;
      }
    });
  }

  Future<void> _openAddressSearch() async {
    final result = await context.push<AddressSearchResult>(
      '${Routes.partnerStore}/${Routes.partnerAddressSearch}',
    );
    debugPrint('[AddressFlow] returned result=$result');
    if (!mounted || result == null) {
      return;
    }
    widget.viewModel.onAction(
      PartnerStoreManagementAction.selectAddressSearchResult(result),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return PartnerStoreManagementScreen(
          state: widget.viewModel.state,
          onAction: widget.viewModel.onAction,
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
