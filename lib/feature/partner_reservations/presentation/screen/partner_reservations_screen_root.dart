import 'dart:async';

import 'package:capstone_2026/feature/partner_reservations/presentation/screen/partner_reservations_action.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/screen/partner_reservations_event.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/screen/partner_reservations_screen.dart';
import 'package:capstone_2026/feature/partner_reservations/presentation/screen/partner_reservations_view_model.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';

class PartnerReservationsScreenRoot extends StatefulWidget {
  final PartnerReservationsViewModel viewModel;

  const PartnerReservationsScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerReservationsScreenRoot> createState() =>
      _PartnerReservationsScreenRootState();
}

class _PartnerReservationsScreenRootState
    extends State<PartnerReservationsScreenRoot> {
  StreamSubscription<PartnerReservationsEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    widget.viewModel.fetch();

    _eventSubscription = widget.viewModel.eventStream.listen(
      (event) {
        if (mounted) {
          switch (event) {
            case ShowMessage(:final message, :final variant):
              AppSnackBar.show(context, message, variant: variant);
              break;
            case OpenDatePicker():
              _openDatePicker(event.selectedDate);
              break;
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return PartnerReservationsScreen(
          state: widget.viewModel.state,
          onAction: (action) {
            switch (action) {
              case TapRetry():
              case TapDateFilter():
              case SelectStatus():
              case SelectDate():
              case TapChangeStatus():
                widget.viewModel.onAction(action);
                break;
            }
          },
        );
      },
    );
  }

  Future<void> _openDatePicker(DateTime? selectedDate) async {
    final now = DateTime.now();

    // datePicker가 닫힐 때까지 대기 후 선택된 날짜를 반환받는다.
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
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

    // 확인으로 날짜를 선택한 경우에만 상태를 갱신한다.
    widget.viewModel.onAction(PartnerReservationsAction.selectDate(pickedDate));
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
