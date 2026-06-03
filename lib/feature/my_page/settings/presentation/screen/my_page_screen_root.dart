import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/screen/my_page_action.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/screen/my_page_screen.dart';
import 'package:capstone_2026/feature/my_page/settings/presentation/screen/my_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyPageScreenRoot extends StatefulWidget {
  final MyPageViewModel viewModel;

  const MyPageScreenRoot({
    super.key,
    required this.viewModel,
  });

  @override
  State<MyPageScreenRoot> createState() => _MyPageScreenRootState();
}

class _MyPageScreenRootState extends State<MyPageScreenRoot> {
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
        return MyPageScreen(
          state: widget.viewModel.state,
          onAction: (action) async {
            switch (action) {
              case ViewNotifications():
                context.push('${Routes.myPage}/${Routes.notifications}');
                break;
              case EditProfile():
                await context.push('${Routes.myPage}/${Routes.profileEdit}');
                widget.viewModel.fetchProfile();
                break;
              case ViewReservationHistory():
                context.push('${Routes.myPage}/${Routes.reservationHistory}');
                break;
              case ViewReviewHistory():
                context.push('${Routes.myPage}/${Routes.reviewHistory}');
                break;
              case ViewStampHistory():
                context.push('${Routes.myPage}/${Routes.stampHistory}');
                break;
              case ViewCouponBox():
                context.push('${Routes.myPage}/${Routes.couponBox}');
                break;
              case TapAccountSettings():
                context.push('${Routes.myPage}/${Routes.accountSettings}');
                break;
              case TapNotificationSettings():
                context.push('${Routes.myPage}/${Routes.notificationSettings}');
                break;
              case TapInquiry():
                context.push('${Routes.myPage}/${Routes.inquiry}');
                break;
              case ViewNotices():
                context.push('${Routes.myPage}/${Routes.notices}');
                break;
              case ViewTerms():
                context.push('${Routes.myPage}/${Routes.terms}');
                break;
            }
          },
        );
      },
    );
  }
}
