import 'package:capstone_2026/core/presentation/util/app_date_picker.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showSignUpDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return AppDatePicker.show(
    context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: firstDate ?? DateTime(1900, 1, 1),
    lastDate: lastDate ?? DateTime(2100, 12, 31),
  );
}
