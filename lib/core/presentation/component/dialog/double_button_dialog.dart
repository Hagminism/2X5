import 'package:capstone_2026/core/presentation/component/dialog/app_confirm_dialog.dart';
import 'package:flutter/material.dart';

@Deprecated('Use AppConfirmDialog or showAppConfirmDialog instead.')
class DoubleButtonDialog extends StatelessWidget {
  final String title;
  final void Function() onPressed;

  const DoubleButtonDialog({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppConfirmDialog(title: title);
  }
}
