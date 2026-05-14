import 'package:capstone_2026/core/domain/model/store/store.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:flutter/material.dart';

class InformationViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;

  InformationViewModel({
    required StoreRepository storeRepository,
  }) : _storeRepository = storeRepository;

  String? _name;
  String? _subtitle;
  double? _rating;
  String? _category;
  bool _isLoading = false;
  String? _errorMessage;

  String get name => _name ?? "";
  String get subtitle => _subtitle ?? "";
  double get rating => _rating ?? 0.0;
  String get category => _category ?? "";
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasStoreData => name.isNotEmpty || subtitle.isNotEmpty;

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

  Future<void> fetchStore(String storeId) async {
    final trimmedStoreId = storeId.trim();
    if (trimmedStoreId.isEmpty) {
      _errorMessage = '업장 정보를 찾을 수 없습니다.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final store = await _storeRepository.findStoreById(trimmedStoreId);
      if (store == null) {
        _errorMessage = hasStoreData ? null : '업장 정보를 찾을 수 없습니다.';
        return;
      }

      _applyStore(store);
    } catch (e) {
      _errorMessage = hasStoreData ? null : '업장 정보를 불러오지 못했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyStore(Store store) {
    _name = store.name;
    _subtitle = store.address;
    _rating = 0.0;
    _category = store.category;
  }
}
