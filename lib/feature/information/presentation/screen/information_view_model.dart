import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart'; // 리포지토리 임포트

class InformationViewModel extends ChangeNotifier {
  // 1. 봇의 지적사항: Supabase에 직접 접근하지 말고 Repository를 사용하세요.
  // 의존성 주입(DI)을 위해 생성자로 받습니다.
  final StoreRepository _storeRepository;
=======
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase 패키지 임포트

class InformationViewModel extends ChangeNotifier {
  // Supabase 클라이언트 설정 (프로젝트 설정에 맞게 수정하세요)
  final _supabase = Supabase.instance.client;
>>>>>>> 7929117 (상세페이지 store_id로 띄우게금 구현)

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

<<<<<<< HEAD
  // 2. 생성자에서 Repository를 필수로 주입받게 만듭니다.
  InformationViewModel({
    required StoreRepository storeRepository,
  }) : _storeRepository = storeRepository;

=======
>>>>>>> 7929117 (상세페이지 store_id로 띄우게금 구현)
  Future<void> fetchStoreDetails(String storeId) async {
    _isLoading = true;
    notifyListeners();

    try {
<<<<<<< HEAD
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
=======
      // 1. Supabase에서 storeId에 해당하는 데이터를 한 줄(single) 가져옵니다.
      // 아까 SQL로 추가한 rating 컬럼도 자동으로 포함됩니다.
      final data = await _supabase
          .from('stores')
          .select('name, address, rating, category')
          .eq('id', storeId)
          .single();

      // 2. DB에서 가져온 실제 데이터를 필드에 할당합니다.
      _name = data['name']?.toString();
      _address = data['address']?.toString();

      // rating은 num 타입으로 올 수 있으므로 double로 안전하게 변환합니다.
      _rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
      _category = data['category']?.toString();

    } catch (e) {
      // 에러 발생 시 로그를 찍고 상태를 초기화하거나 에러 처리를 합니다.
      debugPrint("데이터 로드 에러 (storeId: $storeId): $e");
    } finally {
      // 3. 로딩 종료 후 화면을 다시 그리도록 알립니다.
>>>>>>> 7929117 (상세페이지 store_id로 띄우게금 구현)
      _isLoading = false;
      notifyListeners();
    }
  }
}