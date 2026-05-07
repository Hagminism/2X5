import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_my_page_state.freezed.dart';

@freezed
abstract class PartnerMyPageState with _$PartnerMyPageState {
  const factory PartnerMyPageState({
    @Default(false) bool isLoading,
    String? userName,
    String? email,
    String? photoUrl,
  }) = _PartnerMyPageState;
}
