import 'package:flutter/material.dart';

class InformationViewModel extends ChangeNotifier {
  String? _name;
  String? _address;
  String? _subtitle;
  double? _rating;
  String? _category;
  bool _isLoading = false;

  String get name => _name ?? "";
  String get address => _address ?? "";
  String get subtitle => _subtitle ?? "";
  double get rating => _rating ?? 0.0;
  String get category => _category ?? "";
  bool get isLoading => _isLoading;

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
    notifyListeners();
  }

  Future<void> fetchStoreDetails(String storeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: 실제 DB 연동 코드 (예: Supabase)
      // final data = await supabase.from('stores').select('name, address').eq('id', storeId).single();

      // 테스트를 위한 가상 네트워크 지연
      await Future.delayed(const Duration(milliseconds: 500));

      // 임시 데이터 할당 (DB에서 가져온 값으로 교체하세요)
      // _name = data['name'];
      // _address = data['address'];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}