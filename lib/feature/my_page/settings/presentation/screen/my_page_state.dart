import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_page_state.freezed.dart';

@freezed
abstract class MyPageState with _$MyPageState {
  const factory MyPageState({
    @Default(false) bool isLoading,
    String? userName,
    String? email,
    String? photoUrl,
  }) = _MyPageState;
}