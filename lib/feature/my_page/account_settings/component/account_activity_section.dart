import 'package:flutter/material.dart';
import 'package:capstone_2026/feature/my_page/account_settings/component/account_setting_primary_button.dart';
import 'package:capstone_2026/feature/my_page/account_settings/domain/model/enum/account_activity.dart';
import 'package:capstone_2026/feature/my_page/account_settings/presentation/screen/account_setting_action.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';

class AccountActivitySection extends StatelessWidget {
  final void Function(AccountSettingAction action) onTap;

  const AccountActivitySection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            '계정 활동',
            style: AppTextStyles.label.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accountActivitySectionHeader,
              letterSpacing: 0.6,
            ),
          ),
        ),
        SizedBox(
          height: 130,
          child: Container(
            decoration: BoxDecoration(
              border: BoxBorder.all(
                color: Colors.transparent,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.builder(
              itemCount: AccountActivity.values.length,
              itemBuilder: (context, index) {
                return AccountSettingPrimaryButton(
                  onTap: () {
                    switch (AccountActivity.values[index]) {
                      case AccountActivity.signOut:
                        onTap(AccountSettingAction.tapSignOutButton());
                        break;
                      case AccountActivity.deleteAccount:
                        onTap(AccountSettingAction.tapDeleteAccountButton());
                        break;
                    }
                  },
                  leading: _buildListLeading(AccountActivity.values[index]),
                  title: AccountActivity.values[index].toDisplayName(),
                  borderRadius: _buildListBorderRadius(index),
                  titleColor: _buildListTitleColor(
                    AccountActivity.values[index],
                  ),
                  showArrow: true,
                  arrowColor: _buildArrowColor(AccountActivity.values[index]),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '회원 탈퇴 시 모든 데이터가 영구적으로 삭제되며 복구할 수 없습니다.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.accountActivitySectionHeader,
            ),
          ),
        ),
      ],
    );
  }

  Container _buildListLeading(AccountActivity accountActivity) {
    Color containerColor;
    Icon icon;

    switch (accountActivity) {
      case AccountActivity.signOut:
        containerColor = AppColors.signOutLeading;
        icon = Icon(
          size: 20,
          Icons.logout,
          color: AppColors.signOutLeadingContent,
        );
        break;
      case AccountActivity.deleteAccount:
        containerColor = AppColors.deleteAccountLeading;
        icon = Icon(
          size: 20,
          Icons.person_remove,
          color: AppColors.deleteAccountLeadingContent,
        );
        break;
    }

    final leading = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: icon,
    );

    return leading;
  }

  BorderRadius _buildListBorderRadius(int index) {
    if (index == 0) {
      return BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      );
    } else if (index == AccountActivity.values.length - 1) {
      return BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      );
    } else {
      return BorderRadius.zero;
    }
  }

  Color _buildListTitleColor(AccountActivity accountActivity) {
    switch (accountActivity) {
      case AccountActivity.signOut:
        return AppColors.signOutTitle;
      case AccountActivity.deleteAccount:
        return AppColors.deleteAccountTitle;
    }
  }

  Color _buildArrowColor(AccountActivity accountActivity) {
    switch (accountActivity) {
      case AccountActivity.signOut:
        return AppColors.signOutArrow;
      case AccountActivity.deleteAccount:
        return AppColors.deleteAccountArrow;
    }
  }
}
