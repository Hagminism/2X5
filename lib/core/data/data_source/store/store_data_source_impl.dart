import 'package:capstone_2026/core/data/data_source/store/store_data_source.dart';
import 'package:capstone_2026/core/data/dto/store/store_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoreDataSourceImpl implements StoreDataSource {
  final SupabaseClient _supabaseClient;

  StoreDataSourceImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  @override
  Future<StoreDto?> findStoreByOwnerId(String ownerId) async {
    final json = await _supabaseClient
        .from('stores')
        .select()
        .eq('owner_id', ownerId)
        .maybeSingle();

    if (json == null) {
      return null;
    }

    return StoreDto.fromJson(json);
  }

  @override
  Future<StoreDto> createStore(StoreDto storeDto) async {
    final payload = storeDto.toJson()
      ..remove('id')
      ..remove('created_at');

    final json = await _supabaseClient
        .from('stores')
        .insert(payload)
        .select()
        .single();

    return StoreDto.fromJson(json);
  }

  @override
  Future<StoreDto> updateStoreById(String id, StoreDto storeDto) async {
    final payload = storeDto.toJson()
      ..remove('id')
      ..remove('created_at');

    final json = await _supabaseClient
        .from('stores')
        .update(payload)
        .eq('id', id)
        .select()
        .single();

    return StoreDto.fromJson(json);
  }
}
