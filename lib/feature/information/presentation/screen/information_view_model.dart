import 'package:flutter/material.dart';

class InformationViewModel extends ChangeNotifier {
  String? _name;
  String? _subtitle;
  double? _rating;
  String? _category;//스터디 카페인지 아닌지 확인하기위한 필드

  // getter들이 필드 값을 제대로 반환하는지 확인
  String get name => _name ?? "";
  String get subtitle => _subtitle ?? "";
  double get rating => _rating ?? 0.0;
  String get category => _category ?? "";

  void setInitialData({
    required String name,
    required String subtitle,
    required double rating,
    String? category,
  }) {
    _name = name;
    _subtitle = subtitle;
    _rating = rating;
    _category = category;
    notifyListeners(); // 이 부분이 호출되어야 ListenableBuilder가 화면을 다시 그립니다.
  }
}
