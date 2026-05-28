import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/domain/model/enum/week_day.dart';
import 'package:capstone_2026/feature/partner_page/presentation/component/partner_form_text_field.dart';
import 'package:capstone_2026/feature/partner_page/presentation/component/partner_reservation_slot_minutes_selector.dart';
import 'package:capstone_2026/feature/partner_page/presentation/component/partner_store_management_cta_card.dart';
import 'package:capstone_2026/feature/partner_page/presentation/component/partner_store_management_day_operating_row.dart';
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
    if (!state.isFormVisible) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            SafeArea(
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
                        text: state.isLoadingInitialData
                            ? '사업자등록번호 불러오는 중...'
                            : '업장 정보 등록하기',
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
            if (state.isLoadingInitialData)
              ModalBarrier(
                dismissible: false,
                color: AppColors.black.withValues(alpha: 0.2588),
              ),
            if (state.isLoadingInitialData)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
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
                      state.isEditMode ? '업장 정보 수정' : '업장 정보 등록',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Text(
                      state.isEditMode
                          ? '현재 업장 정보를 확인하고\n필요한 항목을 수정해 주세요.'
                          : '업장 기본 정보를 입력하면\n파트너 관리 기능을 활성화할 수 있어요.',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  PartnerStoreSectionCard(
                    title: '기본 정보',
                    isRequired: true,
                    child: Column(
                      children: [
                        PartnerFormTextField(
                          hintText: '업장명',
                          initialValue: state.storeName,
                          onChanged: (value) => onAction(
                            PartnerStoreManagementAction.changeStoreName(value),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: state.category.isEmpty
                              ? null
                              : StoreCategory.fromDbValue(
                                  state.category,
                                )?.dbValue,
                          borderRadius: BorderRadius.circular(12),
                          dropdownColor: AppColors.white,
                          decoration: _inputDecoration(hintText: '업종'),
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
                              PartnerStoreManagementAction.changeCategory(
                                value,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        PartnerFormTextField(
                          hintText: '사업자등록번호',
                          initialValue: '사업자등록번호: ${state.businessNumber}',
                          isInteractive: false,
                          keyboardType: TextInputType.number,
                          onChanged: (value) => onAction(
                            PartnerStoreManagementAction.changeBusinessNumber(
                              value,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        PartnerFormTextField(
                          hintText: '매장 연락처',
                          initialValue: state.storeContact,
                          keyboardType: TextInputType.phone,
                          onChanged: (value) => onAction(
                            PartnerStoreManagementAction.changeStoreContact(
                              value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PartnerStoreSectionCard(
                    title: '위치 정보',
                    isRequired: true,
                    child: Column(
                      children: [
                        PartnerFormTextField(
                          hintText: '주소',
                          initialValue: state.address,
                          isInteractive: false,
                          onTap: () => onAction(
                            const PartnerStoreManagementAction.tapAddressSearch(),
                          ),
                          onChanged: (_) {},
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '주소를 선택하면 좌표는 자동으로 저장됩니다.',
                              style: AppTextStyles.bodySecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.category != 'study_cafe') ...[
                    const SizedBox(height: 24),
                    PartnerStoreSectionCard(
                      title: '예약금 설정',
                      isRequired: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '예약금 사용',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Switch(
                                value: state.depositEnabled,
                                activeThumbColor: AppColors.primary,
                                onChanged: (value) => onAction(
                                  PartnerStoreManagementAction.changeDepositEnabled(
                                    value,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          PartnerFormTextField(
                            hintText: '예약금 금액(원)',
                            initialValue: state.depositAmount,
                            keyboardType: TextInputType.number,
                            isInteractive: state.depositEnabled,
                            onChanged: (value) => onAction(
                              PartnerStoreManagementAction.changeDepositAmount(
                                value,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.depositEnabled
                                ? '예약금 사용 시 0원보다 큰 금액을 입력해 주세요.'
                                : '예약금을 사용하지 않으면 금액은 자동으로 0원으로 저장됩니다.',
                            style: AppTextStyles.bodySecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  PartnerStoreSectionCard(
                    title: '예약 슬롯 설정',
                    isRequired: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PartnerReservationSlotMinutesSelector(
                          selectedSlotMinutes: state.reservationSlotMinutes,
                          onChanged: (minutes) {
                            onAction(
                              PartnerStoreManagementAction.changeReservationSlotMinutes(
                                minutes,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '선택한 슬롯 단위는 저장 버튼을 눌렀을 때 반영됩니다.',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PartnerStoreSectionCard(
                    title: '운영 정보',
                    isRequired: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final day in WeekDay.values) ...[
                          PartnerStoreManagementDayOperatingRow(
                            dayLabel: day.label,
                            isOpened:
                                (state.operatingHours[day.dbKey]?['isOpened'] ==
                                true),
                            openTime:
                                (state.operatingHours[day.dbKey]?['openTime']
                                    as String?) ??
                                '',
                            closeTime:
                                (state.operatingHours[day.dbKey]?['closeTime']
                                    as String?) ??
                                '',
                            onToggleOpened: (value) => onAction(
                              PartnerStoreManagementAction.toggleDayOpened(
                                day: day.dbKey,
                                isOpened: value,
                              ),
                            ),
                            onSelectOpenTime: (value) => onAction(
                              PartnerStoreManagementAction.changeDayOpenTime(
                                day: day.dbKey,
                                value: value,
                              ),
                            ),
                            onSelectCloseTime: (value) => onAction(
                              PartnerStoreManagementAction.changeDayCloseTime(
                                day: day.dbKey,
                                value: value,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PartnerStoreSectionCard(
                    title: '가게 정보',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PartnerFormTextField(
                          hintText: '매장 소개, 주차 안내, 이용 안내 등을 자유롭게 입력해 주세요.',
                          initialValue: state.description,
                          maxLines: 8,
                          onChanged: (value) => onAction(
                            PartnerStoreManagementAction.changeDescription(
                              value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PartnerStoreSectionCard(
                    title: '스탬프 및 쿠폰 설정',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '스탬프 시스템 사용',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Switch(
                              value: state.isStampEnabled,
                              activeThumbColor: AppColors.primary,
                              onChanged: (value) => onAction(
                                PartnerStoreManagementAction.changeStampEnabled(
                                  value,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (state.isStampEnabled) ...[
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            initialValue: state.stampGoalCount,
                            borderRadius: BorderRadius.circular(12),
                            dropdownColor: AppColors.white,
                            decoration: _inputDecoration(hintText: '목표 스탬프 개수'),
                            items: [5, 10, 15, 20]
                                .map(
                                  (count) => DropdownMenuItem(
                                    value: count,
                                    child: Text('$count개'),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              onAction(
                                PartnerStoreManagementAction.changeStampGoalCount(
                                  value,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          PartnerFormTextField(
                            hintText: '쿠폰 보상 혜택 제목 (예: 제조 음료 1잔 무료 제공)',
                            initialValue: state.stampRewardTitle,
                            onChanged: (value) => onAction(
                              PartnerStoreManagementAction.changeStampRewardTitle(
                                value,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          PartnerFormTextField(
                            hintText: '쿠폰 보상 상세 설명 (예: 제조 음료 중 원하는 음료 1잔을 선택할 수 있는 쿠폰입니다.)',
                            initialValue: state.stampRewardDescription,
                            maxLines: 3,
                            onChanged: (value) => onAction(
                              PartnerStoreManagementAction.changeStampRewardDescription(
                                value,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '스탬프 적립을 설정하면 이용 완료 리뷰 작성 시 고객에게 자동으로 스탬프가 지급됩니다.',
                            style: AppTextStyles.bodySecondary,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (state.category == 'restaurant' ||
                      state.category == 'cafe') ...[
                    const SizedBox(height: 24),
                    _buildGatedSection(
                      title: '메뉴 정보',
                      canAccess: state.canAccessStoreSubManagers,
                      child: PartnerStoreManagementCtaCard(
                        icon: Icons.restaurant_menu_rounded,
                        title: '메뉴 관리',
                        subtitle: '대표 메뉴, 가격, 설명을 등록하고 수정할 수 있어요.',
                        onTap: state.canAccessStoreSubManagers
                            ? () {
                                onAction(
                                  const PartnerStoreManagementAction.tapOpenMenuManager(),
                                );
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildGatedSection(
                      title: '구조 관리',
                      canAccess: state.canAccessStoreSubManagers,
                      child: PartnerStoreManagementCtaCard(
                        icon: Icons.layers_outlined,
                        title: '내부 구조 설정',
                        subtitle: '매장 내부의 테이블 및 구조물 배치를 설정할 수 있어요.',
                        onTap: state.canAccessStoreSubManagers
                            ? () {
                                onAction(
                                  const PartnerStoreManagementAction.tapOpenLayoutManager(),
                                );
                              }
                            : null,
                      ),
                    ),
                  ],
                  if (state.category == 'study_cafe') ...[
                    const SizedBox(height: 24),
                    _buildGatedSection(
                      title: '좌석 관리',
                      canAccess: state.canAccessStoreSubManagers,
                      child: PartnerStoreManagementCtaCard(
                        icon: Icons.chair_alt_rounded,
                        title: '좌석 배치',
                        subtitle: '스터디카페 좌석 구성을 확인하고 조정할 수 있어요.',
                        onTap: state.canAccessStoreSubManagers
                            ? () {
                                onAction(
                                  const PartnerStoreManagementAction.tapOpenSeatLayoutManager(),
                                );
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildGatedSection(
                      title: '이용권 관리',
                      canAccess: state.canAccessStoreSubManagers,
                      child: PartnerStoreManagementCtaCard(
                        icon: Icons.confirmation_number_outlined,
                        title: '이용권 설정',
                        subtitle: '이용 시간·가격·판매 여부를 설정할 수 있어요.',
                        onTap: state.canAccessStoreSubManagers
                            ? () {
                                onAction(
                                  const PartnerStoreManagementAction.tapOpenStudyCafeUsageOptionManager(),
                                );
                              }
                            : null,
                      ),
                    ),
                  ],
                  if (state.category == 'salon') ...[
                    const SizedBox(height: 24),
                    _buildGatedSection(
                      title: '미용실 관리',
                      canAccess: state.canAccessStoreSubManagers,
                      child: PartnerStoreManagementCtaCard(
                        icon: Icons.content_cut_rounded,
                        title: '디자이너/시술 관리',
                        subtitle: '디자이너, 시술, 근무표와 예약 슬롯 단위를 관리해요.',
                        onTap: state.canAccessStoreSubManagers
                            ? () {
                                onAction(
                                  const PartnerStoreManagementAction.tapOpenSalonManager(),
                                );
                              }
                            : null,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildGatedSection(
                    title: '업장 사진',
                    canAccess: state.canAccessStoreSubManagers,
                    child: PartnerStoreManagementCtaCard(
                      icon: Icons.add_a_photo_outlined,
                      title: '업장 사진 관리',
                      subtitle: '갤러리에서 선택한 사진을 업로드해 노출할 수 있어요.',
                      onTap: state.canAccessStoreSubManagers
                          ? () {
                              onAction(
                                const PartnerStoreManagementAction.tapOpenImageManager(),
                              );
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Opacity(
                    opacity: state.canSubmit ? 1 : 0.45,
                    child: IgnorePointer(
                      ignoring: !state.canSubmit || state.isLoadingInitialData,
                      child: PrimaryButton(
                        text: state.isSubmitting
                            ? '저장 중...'
                            : (state.isEditMode ? '수정 저장' : '등록 제출'),
                        onTap: () {
                          onAction(
                            const PartnerStoreManagementAction.tapSubmit(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (state.isSubmitting)
          ModalBarrier(
            dismissible: false,
            color: AppColors.black.withValues(alpha: 0.2588),
          ),
        if (state.isSubmitting)
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildGatedSection({
    required String title,
    required bool canAccess,
    required Widget child,
  }) {
    return PartnerStoreSectionCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          if (!canAccess) ...[
            const SizedBox(height: 10),
            Text(
              '최초 업장 등록을 완료한 뒤 설정할 수 있어요.',
              style: AppTextStyles.bodySecondary.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
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
