import 'package:capstone_2026/feature/my_page/settings/presentation/component/my_menu_section.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/component/my_menu_tile.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/component/my_page_header.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/component/my_profile_card.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/screen/my_page_action.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/screen/my_page_state.dart';
import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  final MyPageState state;
  final void Function(MyPageAction) onAction;

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
              MyPageHeader(
                onTap: () => onAction(const MyPageAction.viewNotifications()),
              ),
              const SizedBox(height: 16),
              MyProfileCard(
                name: state.userName,
                email: state.email,
                photoUrl: state.photoUrl,
                onTap: () => onAction(const MyPageAction.editProfile()),
              ),
              const SizedBox(height: 20),
              MyMenuSection(
                title: '내 활동',
                children: [
                  MyMenuTile(
                    title: '이용 내역',
                    icon: Icons.history_rounded,
                    onTap: () =>
                        onAction(const MyPageAction.viewReservationHistory()),
                  ),
                  MyMenuTile(
                    title: '리뷰 내역',
                    icon: Icons.rate_review_outlined,
                    onTap: () =>
                        onAction(const MyPageAction.viewReviewHistory()),
                  ),
                  MyMenuTile(
                    title: '스탬프 현황',
                    icon: Icons.card_giftcard_rounded,
                    onTap: () =>
                        onAction(const MyPageAction.viewStampHistory()),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              MyMenuSection(
                title: '설정 및 안내',
                children: [
                  MyMenuTile(
                    title: '계정 설정',
                    icon: Icons.person_outline,
                    onTap: () =>
                        onAction(const MyPageAction.tapAccountSettings()),
                  ),
                  MyMenuTile(
                    title: '알림 설정',
                    icon: Icons.notifications_active_outlined,
                    onTap: () => onAction(
                      const MyPageAction.tapNotificationSettings(),
                    ),
                  ),
                  MyMenuTile(
                    title: '1:1 문의',
                    icon: Icons.mail_outline_rounded,
                    onTap: () => onAction(const MyPageAction.tapInquiry()),
                  ),
                  MyMenuTile(
                    title: '공지사항',
                    icon: Icons.campaign_outlined,
                    onTap: () => onAction(const MyPageAction.viewNotices()),
                  ),
                  MyMenuTile(
                    title: '이용약관',
                    icon: Icons.description_outlined,
                    onTap: () => onAction(const MyPageAction.viewTerms()),
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
