import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          '이용약관',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('제1장 서비스 이용약관'),
            _SectionBody(
              '제1조 (목적)\n'
              '본 약관은 2X5팀이 제공하는 예약 중개 플랫폼 서비스(이하 "서비스")의 이용 조건 및 절차에 관한 사항을 규정함을 목적으로 합니다.\n\n'
              '제2조 (회원가입)\n'
              '서비스 이용을 위해 소셜 로그인(Google, Kakao, Naver)을 통한 회원가입이 필요합니다. '
              '허위 정보 입력 시 서비스 이용이 제한될 수 있습니다.\n\n'
              '제3조 (회원 탈퇴)\n'
              '회원은 언제든지 서비스 내 계정 설정에서 탈퇴를 요청할 수 있으며, '
              '탈퇴 시 보유한 예약 내역 및 리뷰는 삭제됩니다.\n\n'
              '제4조 (금지 행위)\n'
              '허위 예약, 악의적 리뷰 작성, 타인 계정 도용, 서비스 방해 행위는 금지되며 '
              '위반 시 서비스 이용이 제한될 수 있습니다.',
            ),
            SizedBox(height: 24),
            _SectionTitle('제2장 개인정보 처리방침'),
            _SectionBody(
              '제1조 (수집 항목)\n'
              '서비스 제공을 위해 아래 항목을 수집합니다.\n'
              '· 필수: 이름, 이메일 주소\n'
              '· 선택: 프로필 사진, 위치 정보\n\n'
              '제2조 (수집 목적)\n'
              '· 회원 식별 및 서비스 제공\n'
              '· 예약 내역 관리\n'
              '· 주변 가게 검색 및 지도 서비스 제공\n\n'
              '제3조 (보유 기간)\n'
              '개인정보는 회원 탈퇴 시까지 보유하며, 탈퇴 후 즉시 파기합니다. '
              '단, 관련 법령에 따라 일정 기간 보관이 필요한 경우 해당 기간 동안 보관합니다.\n\n'
              '제4조 (제3자 제공)\n'
              '수집된 개인정보는 원칙적으로 외부에 제공하지 않습니다. '
              '단, 서비스 운영을 위해 Firebase, Supabase 등 클라우드 서비스를 활용합니다.',
            ),
            SizedBox(height: 24),
            _SectionTitle('제3장 위치정보 이용약관'),
            _SectionBody(
              '제1조 (수집 목적)\n'
              '위치 정보는 사용자 주변의 예약 가능한 가게를 지도에 표시하고 '
              '가까운 업장을 추천하기 위한 목적으로만 활용됩니다.\n\n'
              '제2조 (수집 방법)\n'
              '앱 실행 중 사용자의 동의를 받아 기기의 GPS 정보를 수집합니다. '
              '위치 정보 제공을 거부할 경우 지도 기반 서비스 이용이 제한될 수 있습니다.\n\n'
              '제3조 (보유 기간)\n'
              '위치 정보는 서비스 이용 시 실시간으로만 사용되며 별도로 저장하지 않습니다.',
            ),
            SizedBox(height: 32),
            Center(
              child: Text(
                '본 약관은 2026년 4월 29일부터 적용됩니다.',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  final String text;

  const _SectionBody(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.7,
      ),
    );
  }
}
