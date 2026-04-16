import 'package:flutter/material.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';

class TextFieldDialog extends StatelessWidget {
  final String title;
  final void Function() onPressed;
  final void Function(String) onChanged;

  const TextFieldDialog({
    super.key,
    required this.title,
    required this.onPressed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: 다이얼로그 디자인은 추후 변경할 것
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: 330,
        height: 200,
        padding: EdgeInsets.fromLTRB(12, 12, 12, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Spacer(),
            Text(title, style: AppTextStyles.body),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextFormField(onChanged: onChanged, obscureText: true),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '취소',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    onPressed();
                    Navigator.pop(context);
                  },
                  child: Text(
                    '확인',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
