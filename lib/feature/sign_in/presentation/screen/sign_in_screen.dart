import 'package:capstone_2026/core/presentation/component/text_field/custom_text_field.dart';
import 'package:capstone_2026/feature/sign_in/presentation/screen/sign_in_action.dart';
import 'package:capstone_2026/feature/sign_in/presentation/screen/sign_in_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:capstone_2026/core/domain/model/enum/auth_provider.dart';
import 'package:capstone_2026/core/domain/model/enum/text_field_content_type.dart';
import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/feature/sign_in/presentation/component/social_sign_in_button.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';

class SignInScreen extends StatelessWidget {
  final SignInState state;
  final void Function(SignInAction action) onAction;

  const SignInScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        '모든 예약을 한눈에.\n관리는 더 쉽게.',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                          letterSpacing: -0.8,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        '이메일',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        textFieldContentType: TextFieldContentType.email,
                        onChanged: (email) {
                          onAction(SignInAction.changeEmail(email));
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '비밀번호',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        textFieldContentType: TextFieldContentType.password,
                        isObscureText: state.isObscureText,
                        onTap: () {
                          onAction(SignInAction.changeObscureText());
                        },
                        onChanged: (password) {
                          onAction(SignInAction.changePassword(password));
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              onAction(SignInAction.moveToFindPasswordScreen());
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  '비밀번호를 잊으셨나요?',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.2,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Container(
                                  color: AppColors.textSecondary,
                                  width: 143,
                                  height: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        text: '로그인',
                        onTap: () {
                          onAction(SignInAction.tapSignInButton());
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '아직 회원이 아니신가요? ',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.2,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              padding: WidgetStateProperty.all(
                                EdgeInsets.zero,
                              ),
                            ),
                            onPressed: () {
                              onAction(SignInAction.moveToSignUpScreen());
                            },
                            child: const Text(
                              '가입하기',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: AppColors.divider,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            ' SNS 계정으로 간편하게 시작 ',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.1,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: AppColors.divider,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SocialSignInButton(
                            authProvider: AuthProvider.google,
                            onTap: () {
                              onAction(SignInAction.tapGoogleSignInButton());
                            },
                          ),
                          SocialSignInButton(
                            authProvider: AuthProvider.naver,
                            onTap: () {
                              onAction(SignInAction.tapNaverSignInButton());
                            },
                          ),
                          SocialSignInButton(
                            authProvider: AuthProvider.kakao,
                            onTap: () {
                              onAction(SignInAction.tapKakaoSignInButton());
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
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
      ),
    );
  }
}
