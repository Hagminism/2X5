import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/partner_my_page/settings/presentation/screen/partner_my_page_action.dart';
import 'package:capstone_2026/feature/partner_my_page/settings/presentation/screen/partner_my_page_screen.dart';
import 'package:capstone_2026/feature/partner_my_page/settings/presentation/screen/partner_my_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartnerMyPageScreenRoot extends StatefulWidget {
  final PartnerMyPageViewModel viewModel;

  const PartnerMyPageScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<PartnerMyPageScreenRoot> createState() =>
      _PartnerMyPageScreenRootState();
}

class _PartnerMyPageScreenRootState extends State<PartnerMyPageScreenRoot> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return PartnerMyPageScreen(
          state: widget.viewModel.state,
          onAction: (action) {
            switch (action) {
              case ViewNotifications():
                context.push(
                  '${Routes.partnerMyPage}/${Routes.partnerMyPageNotifications}',
                );
                break;
              case EditProfile():
                context.push(
                  '${Routes.partnerMyPage}/${Routes.partnerMyPageProfileEdit}',
                );
                break;
              case ViewReservationHistory():
                context.push(
                  '${Routes.partnerMyPage}/${Routes.partnerMyPageReservationHistory}',
                );
                break;
              case ViewReviewHistory():
                context.push(
                  '${Routes.partnerMyPage}/${Routes.partnerMyPageReviewHistory}',
                );
                break;
              case TapAccountSettings():
                context.push(
                  '${Routes.partnerMyPage}/${Routes.partnerMyPageAccountSettings}',
                );
                break;
              case TapNotificationSettings():
                context.push(
                  '${Routes.partnerMyPage}/${Routes.partnerMyPageNotificationSettings}',
                );
                break;
              case TapInquiry():
                context.push(
                  '${Routes.partnerMyPage}/${Routes.partnerMyPageInquiry}',
                );
                break;
              case ViewNotices():
                context.push(
                  '${Routes.partnerMyPage}/${Routes.partnerMyPageNotices}',
                );
                break;
              case ViewTerms():
                context.push(
                  '${Routes.partnerMyPage}/${Routes.partnerMyPageTerms}',
                );
                break;
            }
          },
        );
      },
    );
  }
}
