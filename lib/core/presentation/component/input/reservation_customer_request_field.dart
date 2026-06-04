import 'package:capstone_2026/core/domain/util/reservation_customer_request.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class ReservationCustomerRequestField extends StatefulWidget {
  final String value;
  final void Function(String value) onChanged;

  const ReservationCustomerRequestField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<ReservationCustomerRequestField> createState() =>
      _ReservationCustomerRequestFieldState();
}

class _ReservationCustomerRequestFieldState
    extends State<ReservationCustomerRequestField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(ReservationCustomerRequestField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('요구사항 (선택)', style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          Text(
            '최대 $reservationCustomerRequestMaxLength자까지 입력할 수 있어요.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            maxLength: reservationCustomerRequestMaxLength,
            maxLines: 4,
            minLines: 3,
            decoration: InputDecoration(
              hintText: '요구사항을 적어주세요',
              hintStyle: AppTextStyles.bodySecondary,
              counterStyle: AppTextStyles.caption,
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}
