import 'package:flutter/material.dart';
import 'package:capstone_2026/core/domain/model/store/store_image.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';

class InformationViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;

  String? _name;
  String? _address;
  double? _rating;
  String? _category;
  List<StoreImage> _images = [];
  bool _isLoading = true;

  String get name => _name ?? "";
  String get address => _address ?? "";
  double get rating => _rating ?? 0.0;
  String get category => _category ?? "";
  List<StoreImage> get images => List.unmodifiable(_images);
  List<String> get imageUrls =>
      _images.map((e) => e.imageUrl).where((u) => u.trim().isNotEmpty).toList();
  bool get isLoading => _isLoading;

  InformationViewModel({
    required StoreRepository storeRepository,
  }) : _storeRepository = storeRepository;

  Future<void> fetchStoreDetails(String storeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait<Object>([
        _storeRepository.getStoreById(storeId),
        _storeRepository.getStoreImagesByStoreId(storeId),
      ]);

      final store = results[0] as dynamic;
      final images = results[1] as List<StoreImage>;

      _name = store.name as String;
      _address = store.address as String;
      _rating = store.rating as double;
      _category = store.category as String;
      _images = images;
    } catch (e) {
      debugPrint("데이터 로드 에러 (storeId: $storeId): $e");
      _images = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}