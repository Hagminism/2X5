import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_action.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_screen.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartnerSalonManagementScreenRoot extends StatefulWidget {
  final PartnerSalonManagementViewModel viewModel;

  const PartnerSalonManagementScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerSalonManagementScreenRoot> createState() =>
      _PartnerSalonManagementScreenRootState();
}

class _PartnerSalonManagementScreenRootState
    extends State<PartnerSalonManagementScreenRoot> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (BuildContext context, Widget? child) {
        return PartnerSalonManagementScreen(
          state: widget.viewModel.state,
          onAction: (PartnerSalonManagementAction action) {
            switch (action) {
              case PartnerSalonManagementTapBack():
                context.pop();
                break;
              case PartnerSalonManagementOpenDesignerManagement():
                context.push(
                  '${Routes.partnerStore}/${Routes.partnerSalonManagement}/${Routes.partnerSalonDesigners}',
                );
                break;
              case PartnerSalonManagementOpenServiceManagement():
                context.push(
                  '${Routes.partnerStore}/${Routes.partnerSalonManagement}/${Routes.partnerSalonServices}',
                );
                break;
              case PartnerSalonManagementOpenScheduleManagement():
                context.push(
                  '${Routes.partnerStore}/${Routes.partnerSalonManagement}/${Routes.partnerSalonSchedules}',
                );
                break;
            }
          },
        );
      },
    );
  }
}
