import 'package:capstone_2026/core/domain/model/enum/auth_provider.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class SelectAuthProviderButton extends StatelessWidget {
  final AuthProvider authProvider;
  final void Function() onTap;

  const SelectAuthProviderButton({
    super.key,
    required this.authProvider,
    required this.onTap,
  });

  static const TextStyle _buttonTextBase = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: buildColor(authProvider),
            border:
                authProvider == AuthProvider.email ||
                    authProvider == AuthProvider.google
                ? Border.all(color: AppColors.border)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildIcon(authProvider),
              const SizedBox(width: 10),
              buildText(authProvider),
            ],
          ),
        ),
      ),
    );
  }

  Color buildColor(AuthProvider authProvider) {
    switch (authProvider) {
      case AuthProvider.email:
        return AppColors.signUpWithEmailButton;
      case AuthProvider.google:
        return AppColors.signUpWithGoogleButton;
      case AuthProvider.naver:
        return AppColors.signUpWithNaverButton;
      case AuthProvider.kakao:
        return AppColors.signUpWithKakaoButton;
    }
  }

  Color buildTextColor(AuthProvider authProvider) {
    switch (authProvider) {
      case AuthProvider.email:
        return AppColors.signUpWithEmailButtonText;
      case AuthProvider.google:
        return AppColors.signUpWithGoogleButtonText;
      case AuthProvider.naver:
        return AppColors.signUpWithNaverButtonText;
      case AuthProvider.kakao:
        return AppColors.signUpWithKakaoButtonText;
    }
  }

  Widget buildIcon(AuthProvider authProvider) {
    switch (authProvider) {
      case AuthProvider.email:
        return Icon(
          Icons.email_outlined,
          size: 22,
          color: buildTextColor(authProvider),
        );
      case AuthProvider.google:
        return Image.asset(
          'assets/icons/google.png',
          width: 22,
          height: 22,
        );
      case AuthProvider.naver:
        return Image.asset(
          'assets/icons/naver.png',
          width: 22,
          height: 22,
        );
      case AuthProvider.kakao:
        return Image.asset(
          'assets/icons/kakao.png',
          width: 22,
          height: 22,
        );
    }
  }

  Widget buildText(AuthProvider authProvider) {
    final title = '${authProvider.toDisplayName()}로 회원가입';

    return Text(
      title,
      style: _buttonTextBase.copyWith(
        color: buildTextColor(authProvider),
      ),
    );
  }
}
