import 'package:flutter/material.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';

class InformationViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;

  String? _name;
  String? _address;
  double? _rating;
  String? _category;
  bool _isLoading = true;

  String get name => _name ?? "";
  String get address => _address ?? "";
  double get rating => _rating ?? 0.0;
  String get category => _category ?? "";
  bool get isLoading => _isLoading;

  InformationViewModel({
    required StoreRepository storeRepository,
  }) : _storeRepository = storeRepository;

  Future<void> fetchStoreDetails(String storeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final store = await _storeRepository.getStoreById(storeId);
      _name = store.name;
      _address = store.address;
      _rating = store.rating;
      _category = store.category;
    } catch (e) {
      debugPrint("데이터 로드 에러 (storeId: $storeId): $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}