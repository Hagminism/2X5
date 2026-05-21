import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_action.dart';
import 'package:capstone_2026/feature/partner_salon_management/presentation/screen/partner_salon_management_state.dart';
import 'package:flutter/foundation.dart';

class PartnerSalonManagementViewModel extends ChangeNotifier {
  final PartnerSalonManagementState _state =
      const PartnerSalonManagementState();

  PartnerSalonManagementViewModel();

  PartnerSalonManagementState get state => _state;

  void initialize() {}

  void onAction(PartnerSalonManagementAction action) {
    switch (action) {
      case PartnerSalonManagementTapBack():
      case PartnerSalonManagementOpenDesignerManagement():
      case PartnerSalonManagementOpenServiceManagement():
      case PartnerSalonManagementOpenScheduleManagement():
        break;
    }
  }
}
