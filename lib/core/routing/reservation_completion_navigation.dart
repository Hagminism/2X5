import 'package:capstone_2026/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 예약 완료 후 진입 경로의 매장 상세로 이동한다.
void navigateToStoreDetailAfterReservation(BuildContext context) {
  final location = GoRouterState.of(context).matchedLocation;
  final target = location
      .replaceAll('/${Routes.salonReservationConfirm}', '')
      .replaceAll('/${Routes.salonReservation}', '')
      .replaceAll('/${Routes.reservation}', '');

  if (target.isEmpty || target == '/') {
    context.go(Routes.home);
    return;
  }
  context.go(target);
}
