import 'package:capstone_2026/feature/partner_my_page/settings/presentation/component/partner_my_menu_section.dart';
import 'package:capstone_2026/feature/partner_my_page/settings/presentation/component/partner_my_menu_tile.dart';
import 'package:capstone_2026/feature/partner_my_page/settings/presentation/component/partner_my_page_header.dart';
import 'package:capstone_2026/feature/partner_my_page/settings/presentation/component/partner_my_profile_card.dart';
import 'package:capstone_2026/feature/partner_my_page/settings/presentation/screen/partner_my_page_action.dart';
import 'package:capstone_2026/feature/partner_my_page/settings/presentation/screen/partner_my_page_state.dart';
import 'package:flutter/material.dart';

class PartnerMyPageScreen extends StatelessWidget {
  final PartnerMyPageState state;
  final void Function(PartnerMyPageAction) onAction;

  const PartnerMyPageScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PartnerMyPageHeader(
                onTap: () => onAction(PartnerMyPageAction.viewNotifications()),
              ),
              const SizedBox(height: 16),
              PartnerMyProfileCard(
                name: state.userName,
                email: state.email,
                onTap: () => onAction(PartnerMyPageAction.editProfile()),
                photoUrl: state.photoUrl,
              ),
              const SizedBox(height: 20),
              PartnerMyMenuSection(
                title: '설정 및 안내',
                children: [
                  PartnerMyMenuTile(
                    title: '계정 설정',
                    icon: Icons.person_outline,
                    onTap: () => onAction(PartnerMyPageAction.tapAccountSettings()),
                  ),
                  PartnerMyMenuTile(
                    title: '알림 설정',
                    icon: Icons.notifications_active_outlined,
                    onTap: () => onAction(
                      PartnerMyPageAction.tapNotificationSettings(),
                    ),
                  ),
                  PartnerMyMenuTile(
                    title: '1:1 문의',
                    icon: Icons.mail_outline_rounded,
                    onTap: () => onAction(PartnerMyPageAction.tapInquiry()),
                  ),
                  PartnerMyMenuTile(
                    title: '공지사항',
                    icon: Icons.campaign_outlined,
                    onTap: () => onAction(PartnerMyPageAction.viewNotices()),
                  ),
                  PartnerMyMenuTile(
                    title: '이용약관',
                    icon: Icons.description_outlined,
                    onTap: () => onAction(PartnerMyPageAction.viewTerms()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
