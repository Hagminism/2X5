import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/feature/partner_page/presentation/component/partner_store_section_card.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_action.dart';
import 'package:capstone_2026/feature/partner_page/presentation/screen/partner_store_management_state.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';

class PartnerStoreManagementScreen extends StatelessWidget {
  final PartnerStoreManagementState state;
  final void Function(PartnerStoreManagementAction action) onAction;

  const PartnerStoreManagementScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isSubmitted) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  '업장 등록이 완료되었습니다.',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text('(임시 관리 화면)', style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
        ),
      );
    }

    if (!state.isFormVisible) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      color: AppColors.primary,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '업장 정보를 등록해\n파트너 운영을 시작해보세요',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '업장 등록이 완료되면 예약 운영에 필요한 관리 기능을 사용할 수 있어요.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: '업장 정보 등록하기',
                    onTap: () {
                      onAction(
                        const PartnerStoreManagementAction.tapShowRegistrationForm(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Text(
                  '업장 정보 등록',
                  style: AppTextStyles.headline.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Text(
                  '업장 기본 정보를 입력하면\n파트너 관리 기능을 활성화할 수 있어요.',
                  style: AppTextStyles.bodySecondary,
                ),
              ),
              const SizedBox(height: 24),
              PartnerStoreSectionCard(
                title: '기본 정보',
                child: Column(
                  children: [
                    _buildTextField(
                      label: '업장명',
                      initialValue: state.storeName,
                      onChanged: (value) => onAction(
                        PartnerStoreManagementAction.changeStoreName(value),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: state.category.isEmpty
                          ? null
                          : StoreCategory.fromDbValue(state.category)?.dbValue,
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: AppColors.white,
                      decoration: _inputDecoration('업종'),
                      items: StoreCategory.values
                          .map(
                            (category) => DropdownMenuItem(
                              value: category.dbValue,
                              child: Text(category.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        onAction(
                          PartnerStoreManagementAction.changeCategory(value),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: '사업자등록번호',
                      hintText: '숫자 10자리',
                      initialValue: state.businessNumber,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => onAction(
                        PartnerStoreManagementAction.changeBusinessNumber(
                          value,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: '연락처',
                      hintText: '예: 02-1234-5678',
                      initialValue: state.contact,
                      keyboardType: TextInputType.phone,
                      onChanged: (value) => onAction(
                        PartnerStoreManagementAction.changeContact(value),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PartnerStoreSectionCard(
                title: '위치 정보',
                child: Column(
                  children: [
                    _buildTextField(
                      label: '주소',
                      hintText: '도로명 주소를 입력해 주세요',
                      initialValue: state.address,
                      onChanged: (value) => onAction(
                        PartnerStoreManagementAction.changeAddress(value),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: '위도',
                            initialValue: state.latitude,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (value) => onAction(
                              PartnerStoreManagementAction.changeLatitude(
                                value,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            label: '경도',
                            initialValue: state.longitude,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (value) => onAction(
                              PartnerStoreManagementAction.changeLongitude(
                                value,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PartnerStoreSectionCard(
                title: '운영 정보',
                child: _buildTextField(
                  label: '운영시간',
                  hintText: '예: 평일 09:00-18:00, 주말 휴무',
                  initialValue: state.operatingHours,
                  maxLines: 2,
                  onChanged: (value) => onAction(
                    PartnerStoreManagementAction.changeOperatingHours(value),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Opacity(
                opacity: state.canSubmit ? 1 : 0.45,
                child: IgnorePointer(
                  ignoring: !state.canSubmit,
                  child: PrimaryButton(
                    text: state.isSubmitting ? '제출 중...' : '등록 제출',
                    onTap: () {
                      onAction(const PartnerStoreManagementAction.tapSubmit());
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
      decoration: _inputDecoration(label, hintText: hintText),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      filled: true,
      fillColor: AppColors.signInTextField,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}
