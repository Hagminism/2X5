import 'package:capstone_2026/core/domain/model/enum/text_field_content_type.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextFieldContentType textFieldContentType;
  final bool? isObscureText;
  final void Function()? onTap;

  const CustomTextField({
    super.key,
    required this.textFieldContentType,
    this.isObscureText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.signInTextField,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          buildIcon(textFieldContentType),
          const SizedBox(width: 16.0),
          Expanded(
            child: TextFormField(
              obscureText:
                  (textFieldContentType != TextFieldContentType.email &&
                      isObscureText == true)
                  ? true
                  : false,
              decoration: buildInputDecoration(textFieldContentType),
            ),
          ),
          if ((textFieldContentType == TextFieldContentType.password ||
              textFieldContentType == TextFieldContentType.passwordConfirm) &&
                  isObscureText != null)
            Row(
              children: [
                const SizedBox(width: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 17.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      child: Icon(
                        (isObscureText == true)
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 24,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildIcon(TextFieldContentType textFieldContentType) {
    final IconData iconData;

    switch (textFieldContentType) {
      case TextFieldContentType.name:
        iconData = Icons.person_outline;
        break;
      case TextFieldContentType.email:
        iconData = Icons.email_outlined;
        break;
      case TextFieldContentType.password:
      case TextFieldContentType.passwordConfirm:
        iconData = Icons.lock_outline;
        break;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 17.0),
      child: Icon(
        iconData,
        size: 24,
        color: AppColors.textSecondary,
      ),
    );
  }

  InputDecoration buildInputDecoration(
    TextFieldContentType textFieldContentType,
  ) {
    final String hintText;

    switch (textFieldContentType) {
      case TextFieldContentType.name:
        hintText = '이름을 입력하세요';
        break;
      case TextFieldContentType.email:
        hintText = '이메일 주소를 입력하세요';
        break;
      case TextFieldContentType.password:
        hintText = '비밀번호를 입력하세요';
        break;
      case TextFieldContentType.passwordConfirm:
        hintText = '비밀번호를 다시 한 번 입력하세요';
        break;
    }

    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.body.copyWith(
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      border: InputBorder.none,
    );
  }
}
