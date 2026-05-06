import 'package:capstone_2026/core/presentation/component/button/primary_button.dart';
import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/feature/partner_page/presentation/component/partner_form_text_field.dart';
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
                          : StoreCategory.fromDbValue(state.category)?.dbValue,
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
                          PartnerStoreManagementAction.changeCategory(value),
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
                        PartnerStoreManagementAction.changeStoreContact(value),
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
                    PartnerFormTextField(
                      hintText: (state.address == '') ? '주소' : state.address,
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
              const SizedBox(height: 24),
              PartnerStoreSectionCard(
                title: '운영 정보',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final day in _days) ...[
                      _buildDayOperatingRow(
                        context: context,
                        dayKey: day.$1,
                        dayLabel: day.$2,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
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

  Widget _buildDayOperatingRow({
    required BuildContext context,
    required String dayKey,
    required String dayLabel,
  }) {
    final dayConfig = state.operatingHours[dayKey] ?? const {};
    final isOpened = dayConfig['isOpened'] == true;
    final openTime = dayConfig['openTime'] as String?;
    final closeTime = dayConfig['closeTime'] as String?;
    final hasEqualTimeError =
        isOpened &&
        openTime != null &&
        closeTime != null &&
        openTime.isNotEmpty &&
        closeTime.isNotEmpty &&
        openTime == closeTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                dayLabel,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: isOpened,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => onAction(
                PartnerStoreManagementAction.toggleDayOpened(
                  day: dayKey,
                  isOpened: value,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              isOpened ? '영업' : '휴무',
              style: AppTextStyles.bodySecondary.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildTimeSelectButton(
                context: context,
                isStartTime: true,
                value: openTime ?? '',
                enabled: isOpened,
                onSelected: (value) => onAction(
                  PartnerStoreManagementAction.changeDayOpenTime(
                    day: dayKey,
                    value: value,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '~',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTimeSelectButton(
                context: context,
                isStartTime: false,
                value: closeTime ?? '',
                enabled: isOpened,
                onSelected: (value) => onAction(
                  PartnerStoreManagementAction.changeDayCloseTime(
                    day: dayKey,
                    value: value,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (hasEqualTimeError) ...[
          const SizedBox(height: 6),
          Text(
            '시작 시간과 종료 시간은 같을 수 없습니다.',
            style: AppTextStyles.bodySecondary.copyWith(
              color: AppColors.danger,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeSelectButton({
    required BuildContext context,
    required bool isStartTime,
    required String value,
    required bool enabled,
    required ValueChanged<String> onSelected,
  }) {
    final label = isStartTime ? '시작 시간' : '종료 시간';
    final borderRadius = BorderRadius.circular(12);

    return SizedBox(
      height: 48,
      child: Material(
        color: enabled ? AppColors.signInTextField : AppColors.border,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: !enabled
              ? null
              : () async {
                  final selected = await showTimePicker(
                    context: context,
                    initialTime: _toInitialTime(value),
                    builder: (context, child) {
                      final baseTheme = Theme.of(context);
                      return Theme(
                        data: baseTheme.copyWith(
                          colorScheme: baseTheme.colorScheme.copyWith(
                            primary: AppColors.primary,
                            onPrimary: AppColors.white,
                            surface: AppColors.white,
                            onSurface: AppColors.textPrimary,
                          ),
                          dialogTheme: const DialogThemeData(
                            backgroundColor: AppColors.white,
                          ),
                          timePickerTheme: const TimePickerThemeData(
                            backgroundColor: AppColors.white,
                            hourMinuteColor: AppColors.signInTextField,
                            hourMinuteTextColor: AppColors.textPrimary,
                            dayPeriodColor: AppColors.signInTextField,
                            dayPeriodTextColor: AppColors.textPrimary,
                            dialHandColor: AppColors.primary,
                            dialBackgroundColor: AppColors.signInTextField,
                            entryModeIconColor: AppColors.primary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (selected == null) return;
                  onSelected(_formatTime(selected));
                },
          child: Center(
            child: Text(
              value.isEmpty ? label : value,
              style: AppTextStyles.body.copyWith(
                color: value.isEmpty
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  TimeOfDay _toInitialTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) {
      return TimeOfDay.now();
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return TimeOfDay.now();
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static const List<(String, String)> _days = [
    ('monday', '월'),
    ('tuesday', '화'),
    ('wednesday', '수'),
    ('thursday', '목'),
    ('friday', '금'),
    ('saturday', '토'),
    ('sunday', '일'),
  ];

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
