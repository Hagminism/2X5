import 'package:capstone_2026/core/domain/model/enum/text_field_content_type.dart';
import 'package:capstone_2026/core/presentation/component/app_bar/custom_app_bar.dart';
import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/core/presentation/component/text_field/custom_text_field.dart';
import 'package:capstone_2026/feature/on_boarding_customer/presentation/screen/on_boarding_customer_action.dart';
import 'package:capstone_2026/feature/on_boarding_customer/presentation/screen/on_boarding_customer_state.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/component/sign_up_customer_header.dart';
import 'package:capstone_2026/feature/sign_up_customer/presentation/component/sign_up_customer_terms_row.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class OnBoardingCustomerScreen extends StatelessWidget {
  final OnBoardingCustomerState state;
  final void Function(OnBoardingCustomerAction action) onAction;

  const OnBoardingCustomerScreen({
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
            onTap: () => onAction(OnBoardingCustomerAction.tapBackButton()),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: SignUpCustomerHeader()),
                    const SizedBox(height: 40),
                    buildLabel('이름'),
                    CustomTextField(
                      textFieldContentType: TextFieldContentType.name,
                      onChanged: (name) {
                        onAction(OnBoardingCustomerAction.changeName(name));
                      },
                    ),
                    const SizedBox(height: 28),
                    buildLabel('전화번호'),
                    CustomTextField(
                      textFieldContentType: TextFieldContentType.phone,
                      onChanged: (phone) {
                        onAction(OnBoardingCustomerAction.changePhone(phone));
                      },
                    ),
                    const SizedBox(height: 28),
                    buildLabel('이메일'),
                    CustomTextField(
                      textFieldContentType: TextFieldContentType.email,
                      onChanged: (email) {
                        onAction(OnBoardingCustomerAction.changeEmail(email));
                      },
                    ),
                    const SizedBox(height: 28),
                    buildLabel('비밀번호'),
                    CustomTextField(
                      textFieldContentType: TextFieldContentType.password,
                      isObscureText: state.passwordObscureText,
                      onTap: () {
                        onAction(
                          const OnBoardingCustomerAction.changePasswordObscureText(),
                        );
                      },
                      onChanged: (password) {
                        onAction(
                          OnBoardingCustomerAction.changePassword(password),
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
                          const OnBoardingCustomerAction.changePasswordConfirmObscureText(),
                        );
                      },
                      onChanged: (passwordConfirm) {
                        onAction(
                          OnBoardingCustomerAction.changePasswordConfirm(
                            passwordConfirm,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 36),
                    SignUpCustomerTermsRow(
                      isChecked: state.agreeTerms,
                      onToggle: () => onAction(
                        const OnBoardingCustomerAction.toggleTermsAgreement(),
                      ),
                    ),
                    const SizedBox(height: 36),
                    PrimaryButton(
                      text: '가입하기',
                      onTap: () {
                        onAction(const OnBoardingCustomerAction.tapSubmit());
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
