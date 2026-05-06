import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_menu.freezed.dart';
part 'store_menu.g.dart';

@freezed
abstract class StoreMenu with _$StoreMenu {
  const factory StoreMenu({
    String? id,
    required String name,
    required int price,
    @Default('') String description,
    @Default('') String imageUrl,
    required int sortOrder,
    @Default(true) bool isAvailable,
  }) = _StoreMenu;

  factory StoreMenu.fromJson(Map<String, Object?> json) =>
      _$StoreMenuFromJson(json);
}
