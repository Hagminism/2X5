import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/screen/partner_reservation_slot_settings_screen_root.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/screen/partner_reservation_slot_settings_view_model.dart';
import 'package:flutter/material.dart';

class PartnerReservationSlotSettingsScope extends StatefulWidget {
  final PartnerReservationSlotSettingsViewModel viewModel;

  const PartnerReservationSlotSettingsScope({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerReservationSlotSettingsScope> createState() =>
      _PartnerReservationSlotSettingsScopeState();
}

class _PartnerReservationSlotSettingsScopeState
    extends State<PartnerReservationSlotSettingsScope> {
  late final PartnerReservationSlotSettingsViewModel viewModel =
      widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return PartnerReservationSlotSettingsScreenRoot(viewModel: viewModel);
  }
}
