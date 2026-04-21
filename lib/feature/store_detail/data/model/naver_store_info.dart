import 'package:freezed_annotation/freezed_annotation.dart';

part 'naver_store_info.freezed.dart';
part 'naver_store_info.g.dart';

@freezed
abstract class NaverStoreInfo with _$NaverStoreInfo {
  const factory NaverStoreInfo({
    required String title,
    required String link,
    required String roadAddress,
  }) = _NaverStoreInfo;

  factory NaverStoreInfo.fromJson(Map<String, dynamic> json) =>
      _$NaverStoreInfoFromJson(json);
}
