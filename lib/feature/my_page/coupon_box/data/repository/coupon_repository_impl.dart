import 'package:capstone_2026/feature/my_page/coupon_box/domain/model/coupon.dart';
import 'package:capstone_2026/feature/my_page/coupon_box/domain/repository/coupon_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CouponRepositoryImpl implements CouponRepository {
  CouponRepositoryImpl({
    required SupabaseClient supabase,
  }) : _supabase = supabase;

  final SupabaseClient _supabase;

  @override
  Future<List<Coupon>> fetchUserCoupons({required String userId}) async {
    final response = await _supabase
        .from('coupons')
        .select('*, stores(name, category)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final list = response as List<dynamic>;
    return list.map((json) {
      final map = Map<String, dynamic>.from(json);
      final stores = map['stores'] as Map<String, dynamic>?;
      map['store_name'] = stores?['name'] ?? '';
      map['store_category'] = stores?['category'] ?? '';
      return Coupon.fromJson(map);
    }).toList();
  }

  @override
  Future<void> useCoupon({required String couponId}) async {
    await _supabase
        .from('coupons')
        .update({'used_at': DateTime.now().toIso8601String()})
        .eq('id', couponId);
  }
}
