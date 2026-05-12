import 'package:flutter/material.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart'; // 리포지토리 임포트

class InformationViewModel extends ChangeNotifier {
  // 1. 봇의 지적사항: Supabase에 직접 접근하지 말고 Repository를 사용하세요.
  // 의존성 주입(DI)을 위해 생성자로 받습니다.
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

  // 2. 생성자에서 Repository를 필수로 주입받게 만듭니다.
  InformationViewModel({
    required StoreRepository storeRepository,
  }) : _storeRepository = storeRepository;

  Future<void> fetchStoreDetails(String storeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 3. 봇의 지적사항: ViewModel에서 직접 쿼리(select, eq 등)를 날리지 마세요.
      // 아까 우리가 Repository와 DataSource에 만든 메서드를 호출합니다.
      final store = await _storeRepository.getStoreById(storeId);

      // 4. 이제 데이터는 Map이 아니라 잘 정의된 Store 모델 객체로 들어옵니다.
      _name = store.name;
      _address = store.address;
      _rating = store.rating;
      _category = store.category; // store 모델의 category가 String이면 그대로 사용

    } catch (e) {
      // 에러 처리
      debugPrint("데이터 로드 에러 (storeId: $storeId): $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}