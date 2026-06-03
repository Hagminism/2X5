import 'dart:async';

import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/screen/partner_reservation_slot_settings_action.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/screen/partner_reservation_slot_settings_event.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/screen/partner_reservation_slot_settings_screen.dart';
import 'package:capstone_2026/feature/partner_reservation_slot_settings/presentation/screen/partner_reservation_slot_settings_view_model.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

class PartnerReservationSlotSettingsScreenRoot extends StatefulWidget {
  final PartnerReservationSlotSettingsViewModel viewModel;

  const PartnerReservationSlotSettingsScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerReservationSlotSettingsScreenRoot> createState() =>
      _PartnerReservationSlotSettingsScreenRootState();
}

class _PartnerReservationSlotSettingsScreenRootState
    extends State<PartnerReservationSlotSettingsScreenRoot> {
  StreamSubscription<PartnerReservationSlotSettingsEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
    _eventSubscription = widget.viewModel.eventStream.listen((event) {
      if (!mounted) {
        return;
      }
      switch (event) {
        case OpenDatePicker():
          _openDatePicker(event.selectedDate);
          break;
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
        return PartnerReservationSlotSettingsScreen(
          state: widget.viewModel.state,
          onAction: (action) {
            switch (action) {
              case TapDatePicker():
                widget.viewModel.onAction(action);
                break;
              case SelectDate():
              case ToggleSlotOpen():
              case TapIncreaseMaxGuestCount():
              case TapDecreaseMaxGuestCount():
              case ToggleExceptionClosed():
              case ChangeExceptionOpenTime():
              case ChangeExceptionCloseTime():
              case TapSave():
                widget.viewModel.onAction(action);
                break;
            }
          },
        );
      },
    );
  }

  Future<void> _openDatePicker(DateTime selectedDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
            ),
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (!mounted || pickedDate == null) {
      return;
    }
    widget.viewModel.onAction(SelectDate(pickedDate));
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
