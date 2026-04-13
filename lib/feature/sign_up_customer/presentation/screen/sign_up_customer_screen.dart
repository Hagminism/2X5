import 'package:capstone_2026/feature/sign_up_customer/presentation/screen/sign_up_customer_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';


class SignUpCustomerScreen extends StatelessWidget {
  const SignUpCustomerScreen({
    required this.state,
    required this.onNameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onPasswordConfirmChanged,
    required this.onTermsChanged,
    required this.onSubmit,
    required this.onSignInTap,
    super.key,
  });

  final SignUpCustomerState state;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onPasswordConfirmChanged;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onSubmit;
  final VoidCallback onSignInTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7FAFF), Color(0xFFEFF4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F0F172A),
                        blurRadius: 20,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('회원가입', style: AppTextStyles.headline),
                        const SizedBox(height: 8),
                        const Text(
                          '필수 정보를 입력하고 계정을 생성해 주세요.',
                          style: AppTextStyles.subtitle,
                        ),
                        const SizedBox(height: 24),
                        const Text('이름', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: onNameChanged,
                          decoration: _inputDecoration(
                            hintText: '이름을 입력해 주세요.',
                            icon: Icons.person_outline_rounded,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('이메일', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextField(
                          keyboardType: TextInputType.emailAddress,
                          onChanged: onEmailChanged,
                          decoration: _inputDecoration(
                            hintText: 'example@email.com',
                            icon: Icons.alternate_email_rounded,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('비밀번호', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextField(
                          obscureText: true,
                          onChanged: onPasswordChanged,
                          decoration: _inputDecoration(
                            hintText: '비밀번호를 입력해 주세요.',
                            icon: Icons.lock_outline_rounded,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('비밀번호 확인', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextField(
                          obscureText: true,
                          onChanged: onPasswordConfirmChanged,
                          decoration: _inputDecoration(
                            hintText: '비밀번호를 다시 입력해 주세요.',
                            icon: Icons.verified_user_outlined,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => onTermsChanged(!state.agreeTerms),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: state.agreeTerms,
                                  onChanged: (value) =>
                                      onTermsChanged(value ?? false),
                                ),
                                const Expanded(
                                  child: Text(
                                    '필수 약관에 동의합니다.',
                                    style: AppTextStyles.body,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (state.errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            state.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: state.canSubmit ? onSubmit : null,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: state.isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    '회원가입',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '이미 계정이 있나요?',
                              style: AppTextStyles.subtitle,
                            ),
                            TextButton(
                              onPressed: onSignInTap,
                              child: const Text('로그인'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surfaceMuted,
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
