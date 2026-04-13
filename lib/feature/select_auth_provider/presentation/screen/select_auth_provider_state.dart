import 'package:freezed_annotation/freezed_annotation.dart';

part 'select_auth_provider_state.freezed.dart';

@freezed
abstract class SelectAuthProviderState with _$SelectAuthProviderState {
  const factory SelectAuthProviderState({
    @Default(false) bool isLoading,
    @Default('') String naverState,
  }) = _SelectAuthProviderState;
}
