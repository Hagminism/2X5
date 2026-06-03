import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_dashboard_state.freezed.dart';

@freezed
abstract class PartnerDashboardState with _$PartnerDashboardState {
  const factory PartnerDashboardState({
    @Default(false) bool isLoading,
    @Default(0) int todayPendingCount,
    @Default(0) int todayConfirmedCount,
    @Default(0) int todayCancelledCount,
    @Default('오늘 운영 요약을 불러오는 중입니다.') String summaryMessage,
  }) = _PartnerDashboardState;
}
