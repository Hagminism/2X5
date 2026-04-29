import 'package:capstone_2026/core/domain/model/enum/text_field_content_type.dart';
import 'package:capstone_2026/core/presentation/component/app_bar/custom_app_bar.dart';
import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/core/presentation/component/text_field/custom_text_field.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/component/sign_up_header.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/component/sign_up_terms_row.dart';
import 'package:capstone_2026/feature/sign_up_partner/presentation/sign_up_partner_action.dart';
import 'package:capstone_2026/feature/sign_up_partner/presentation/sign_up_partner_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

import '../../../core/domain/model/enum/user_type.dart';

class SignUpPartnerScreen extends StatelessWidget {
  final SignUpPartnerState state;
  final void Function(SignUpPartnerAction action) onAction;

  const SignUpPartnerScreen({
    required this.state,
    required this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.white,
          appBar: CustomAppBar(
            title: '',
            showBackButton: true,
            onTap: () => onAction(SignUpPartnerAction.tapBackButton()),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: SignUpHeader(
                        userType: UserType.partner,
                      ),
                    ),
                    const SizedBox(height: 40),
                    buildLabel('대표자 성명'),
                    CustomTextField(
                      textFieldContentType: TextFieldContentType.name,
                      onChanged: (name) {
                        onAction(SignUpPartnerAction.changeName(name));
                      },
                    ),
                    const SizedBox(height: 28),
                    buildLabel('전화번호'),
                    CustomTextField(
                      textFieldContentType: TextFieldContentType.phone,
                      onChanged: (phone) {
                        onAction(SignUpPartnerAction.changePhone(phone));
                      },
                    ),
                    const SizedBox(height: 28),
                    buildLabel('이메일'),
                    CustomTextField(
                      textFieldContentType: TextFieldContentType.email,
                      onChanged: (email) {
                        onAction(SignUpPartnerAction.changeEmail(email));
                      },
                    ),
                    const SizedBox(height: 28),
                    buildLabel('비밀번호'),
                    CustomTextField(
                      textFieldContentType: TextFieldContentType.password,
                      isObscureText: state.passwordObscureText,
                      onTap: () {
                        onAction(
                          const SignUpPartnerAction.changePasswordObscureText(),
                        );
                      },
                      onChanged: (password) {
                        onAction(
                          SignUpPartnerAction.changePassword(password),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    buildLabel('비밀번호 확인'),
                    CustomTextField(
                      textFieldContentType:
                          TextFieldContentType.passwordConfirm,
                      isObscureText: state.passwordConfirmObscureText,
                      onTap: () {
                        onAction(
                          const SignUpPartnerAction.changePasswordConfirmObscureText(),
                        );
                      },
                      onChanged: (passwordConfirm) {
                        onAction(
                          SignUpPartnerAction.changePasswordConfirm(
                            passwordConfirm,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 36),
                    SignUpTermsRow(
                      isChecked: state.agreeTerms,
                      onToggle: () => onAction(
                        const SignUpPartnerAction.toggleTermsAgreement(),
                      ),
                    ),
                    const SizedBox(height: 36),
                    PrimaryButton(
                      text: '가입하기',
                      onTap: () {
                        onAction(const SignUpPartnerAction.tapSubmit());
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (state.isLoading)
          ModalBarrier(
            dismissible: false,
            color: AppColors.black.withValues(alpha: 0.2588),
          ),
        if (state.isLoading)
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }

  Widget buildLabel(String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: AppTextStyles.caption.copyWith(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
