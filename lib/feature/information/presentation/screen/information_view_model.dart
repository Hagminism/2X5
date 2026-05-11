import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase 패키지 임포트

class InformationViewModel extends ChangeNotifier {
  // Supabase 클라이언트 설정 (프로젝트 설정에 맞게 수정하세요)
  final _supabase = Supabase.instance.client;

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

  Future<void> fetchStoreDetails(String storeId) async {
    _isLoading = true;
    notifyListeners();

    try {
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
      _isLoading = false;
      notifyListeners();
    }
  }
}