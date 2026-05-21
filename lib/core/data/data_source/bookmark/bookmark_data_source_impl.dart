import 'package:capstone_2026/core/data/data_source/bookmark/bookmark_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookmarkDataSourceImpl implements BookmarkDataSource {
  BookmarkDataSourceImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<bool> exists({
    required String userId,
    required String storeId,
  }) async {
    final row = await _supabaseClient
        .from('store_bookmarks')
        .select('id')
        .eq('user_id', userId)
        .eq('store_id', storeId)
        .maybeSingle();

    return row != null;
  }

  @override
  Future<void> add({
    required String userId,
    required String storeId,
  }) async {
    await _supabaseClient.from('store_bookmarks').insert({
      'user_id': userId,
      'store_id': storeId,
    });
  }

  @override
  Future<void> remove({
    required String userId,
    required String storeId,
  }) async {
    await _supabaseClient
        .from('store_bookmarks')
        .delete()
        .eq('user_id', userId)
        .eq('store_id', storeId);
  }

  @override
  Future<List<Map<String, dynamic>>> findByUserId(String userId) async {
    final rows = await _supabaseClient
        .from('store_bookmarks')
        .select('''
          id,
          created_at,
          store_id,
          stores (
            id,
            name,
            category,
            address,
            rating
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(rows as List);
  }
}