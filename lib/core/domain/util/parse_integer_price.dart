import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:intl/intl.dart';

final RegExp _priceTokenPattern = RegExp(r'(\d{1,3}(?:,\d{3})+|\d+)');

List<int> extractPriceAmounts(Object? raw) {
  if (raw == null) {
    return const [];
  }
  if (raw is int) {
    return [raw];
  }
  if (raw is num) {
    return [raw.toInt()];
  }

  final amounts = <int>[];
  for (final match in _priceTokenPattern.allMatches(raw.toString())) {
    final digits = match.group(1)?.replaceAll(',', '');
    final value = int.tryParse(digits ?? '');
    if (value != null) {
      amounts.add(value);
    }
  }
  return amounts;
}

int parseIntegerPrice(Object? raw, {int fallback = 0}) {
  final amounts = extractPriceAmounts(raw);
  if (amounts.isEmpty) {
    return fallback;
  }

  return amounts.reduce(
    (minValue, value) => value < minValue ? value : minValue,
  );
}

String formatMenuPriceLabel(Object? raw) {
  final amounts = extractPriceAmounts(raw);
  if (amounts.isEmpty) {
    return '';
  }

  final formatter = NumberFormat('#,###', 'ko_KR');
  if (amounts.length == 1) {
    return '${formatter.format(amounts.first)}원';
  }

  final minPrice = amounts.reduce(
    (minValue, value) => value < minValue ? value : minValue,
  );
  final maxPrice = amounts.reduce(
    (maxValue, value) => value > maxValue ? value : maxValue,
  );
  if (minPrice == maxPrice) {
    return '${formatter.format(minPrice)}원';
  }

  return '${formatter.format(minPrice)}~${formatter.format(maxPrice)}원';
}

String resolveMenuPriceLabel(StoreMenu menu) {
  if (menu.priceDisplay.trim().isNotEmpty) {
    return menu.priceDisplay.trim();
  }
  if (menu.price <= 0) {
    return '';
  }

  return '${NumberFormat('#,###', 'ko_KR').format(menu.price)}원';
}
