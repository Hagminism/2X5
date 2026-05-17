import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/domain/model/store/store.dart';
import 'package:capstone_2026/core/domain/model/store/store_image.dart';
import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:flutter/material.dart';

class InformationViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;

  InformationViewModel({
    required StoreRepository storeRepository,
  }) : _storeRepository = storeRepository;

  String? _name;
  String? _address;
  String? _contact;
  String? _phone;
  double? _rating;
  String? _category;
  List<StoreImage> _images = [];
  List<StoreMenu> _menus = [];
  bool _isLoading = true;

  String get name => _name ?? '';
  String get address => _address ?? '';
  String get contact => _contact ?? '';
  double get rating => _rating ?? 0.0;
  String get category => _category ?? '';
  bool get isLoading => _isLoading;

  /// 인포 홈 전화: `stores.phone` 우선, 없으면 `contact`
  String get displayPhone {
    final p = (_phone ?? '').trim();
    if (p.isNotEmpty) return p;
    return (_contact ?? '').trim();
  }

  /// DB `category` → 인포 헤더 서브타이틀용 한글 업종명.
  String get categorySubtitleLabel {
    final raw = (_category ?? '').trim();
    if (raw.isEmpty) return '';

    final parsed = StoreCategory.fromDbValue(raw);
    if (parsed != null) return parsed.displayName;

    switch (raw) {
      case '살롱':
      case '샵':
        return '미용실';
      case '레스토랑':
        return '식당';
      case '카페':
        return '카페';
      case '스터디카페':
      case '스터디 카페':
        return '스터디카페';
      default:
        return raw;
    }
  }

  List<StoreImage> get images => List.unmodifiable(_images);
  List<String> get imageUrls =>
      _images.map((e) => e.imageUrl).where((u) => u.trim().isNotEmpty).toList();
  List<StoreMenu> get menus => List.unmodifiable(_menus);

  Future<void> fetchStoreDetails(String storeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait<Object>([
        _storeRepository.getStoreById(storeId),
        _storeRepository.getStoreImagesByStoreId(storeId),
        _storeRepository.getStoreMenusByStoreId(storeId),
      ]);

      final store = results[0] as Store;
      final images = results[1] as List<StoreImage>;
      final menus = results[2] as List<StoreMenu>;

      _name = store.name;
      _address = store.address;
      _contact = store.contact;
      _phone = store.phone;
      _rating = store.rating;
      _category = store.category;
      _images = images;
      _menus = menus;
    } catch (e) {
      debugPrint('데이터 로드 에러 (storeId: $storeId): $e');
      _images = [];
      _menus = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}