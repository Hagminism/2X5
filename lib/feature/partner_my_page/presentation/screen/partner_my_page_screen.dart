import 'package:capstone_2026/core/domain/repository/auth/auth_repository.dart';
import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/di/di_setup.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerMyPageScreen extends StatefulWidget {
  const PartnerMyPageScreen({super.key});

  @override
  State<PartnerMyPageScreen> createState() => _PartnerMyPageScreenState();
}

class _PartnerMyPageScreenState extends State<PartnerMyPageScreen> {
  bool _isSigningOut = false;

  Future<void> _signOut() async {
    if (_isSigningOut) return;
    setState(() {
      _isSigningOut = true;
    });
    try {
      await getIt<AuthRepository>().signOut();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그아웃 중 오류가 발생했습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSigningOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '마이페이지',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '파트너 계정 설정을 관리해 보세요.',
                style: AppTextStyles.bodySecondary,
              ),
              const Spacer(),
              PrimaryButton(
                text: _isSigningOut ? '로그아웃 중...' : '로그아웃',
                onTap: _signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
