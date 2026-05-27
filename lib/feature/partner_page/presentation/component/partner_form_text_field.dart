import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerFormTextField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool isInteractive;
  final VoidCallback? onTap;

  const PartnerFormTextField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.isInteractive = true,
    this.onTap,
  });

  @override
  State<PartnerFormTextField> createState() => _PartnerFormTextFieldState();
}

class _PartnerFormTextFieldState extends State<PartnerFormTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(PartnerFormTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textField = TextFormField(
      controller: _controller,
      enabled: widget.isInteractive,
      onChanged: widget.isInteractive ? widget.onChanged : null,
      onTap: widget.isInteractive ? widget.onTap : null,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      style: AppTextStyles.body.copyWith(
        color: widget.isInteractive
            ? AppColors.textPrimary
            : AppColors.textSecondary,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: AppColors.signInTextField,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );

    if (widget.onTap == null || widget.isInteractive) {
      return textField;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: AbsorbPointer(child: textField),
      ),
    );
  }
}
