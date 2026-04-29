import 'package:capstone_2026/core/domain/model/enum/text_field_content_type.dart';
import 'package:capstone_2026/core/presentation/component/app_bar/custom_app_bar.dart';
import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/core/presentation/component/text_field/custom_text_field.dart';
import 'package:capstone_2026/feature/admin_onboarding/component/gallery_picker_button.dart';
import 'package:capstone_2026/feature/admin_onboarding/presentation/screen/admin_onboarding_action.dart';
import 'package:capstone_2026/feature/admin_onboarding/presentation/screen/admin_onboarding_state.dart';
import 'package:capstone_2026/feature/sign_up_partner/component/date_picker_button.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class AdminOnboardingScreen extends StatelessWidget {
  final AdminOnboardingState state;
  final void Function(AdminOnboardingAction action) onAction;

  const AdminOnboardingScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isPending) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: const CustomAppBar(title: '관리자 인증', showBackButton: false),
        body: const SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '사업자 인증 심사 중입니다.\n승인 후 관리자 기능이 활성화됩니다.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '사업자 인증 정보를 입력해 주세요',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                     fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                _buildLabel('대표자명'),
                CustomTextField(
                  textFieldContentType: TextFieldContentType.name,
                  onChanged: (value) {
                    onAction(AdminOnboardingAction.changeRepresentativeName(value));
                  },
                ),
                const SizedBox(height: 28),
                _buildLabel('사업자등록번호'),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: CustomTextField(
                        textFieldContentType: TextFieldContentType.businessNumber,
                        onChanged: (value) {
                          onAction(
                            AdminOnboardingAction.changeBusinessNumber(value),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PrimaryButton(
                        text: state.isVerifyingBusinessNumber ? '검증 중' : '제출',
                        onTap: state.isVerifyingBusinessNumber
                            ? () {}
                            : () {
                                onAction(
                                  const AdminOnboardingAction.tapVerifyBusinessNumber(),
                                );
                              },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  state.isBusinessNumberVerified
                      ? '검증 완료'
                      : '사업자등록번호 검증이 필요합니다.',
                  style: AppTextStyles.caption.copyWith(
                    color: state.isBusinessNumberVerified
                        ? Colors.green
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                _buildLabel('개업일자'),
                DatePickerButton(
                  labelText: state.openedOn == null
                      ? '개업일자를 선택하세요'
                      : MaterialLocalizations.of(context).formatFullDate(
                          state.openedOn!,
                        ),
                  onTap: () {
                    onAction(const AdminOnboardingAction.tapPickOpenedOn());
                  },
                ),
                const SizedBox(height: 28),
                _buildLabel('사업자등록증 첨부'),
                GalleryPickerButton(
                  labelText: state.isUploadingLicenseImage
                      ? '업로드 중...'
                      : (state.licenseImageUrl == null
                            ? '갤러리에서 등록증 이미지를 선택하세요'
                            : '등록증 이미지 선택 완료'),
                  onTap: state.isUploadingLicenseImage
                      ? () {}
                      : () {
                          onAction(const AdminOnboardingAction.tapPickLicenseImage());
                        },
                ),
                const SizedBox(height: 40),
                Opacity(
                  opacity: state.canSubmit ? 1 : 0.45,
                  child: IgnorePointer(
                    ignoring: !state.canSubmit,
                    child: PrimaryButton(
                      text: state.isSubmitting ? '제출 중...' : '최종 제출',
                      onTap: () {
                        onAction(const AdminOnboardingAction.tapSubmit());
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String labelText) {
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
