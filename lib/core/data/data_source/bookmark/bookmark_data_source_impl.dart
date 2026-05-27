import 'dart:async';

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
            rating,
            store_images (
              image_url,
              is_cover,
              sort_order
            ),
            reviews(count)
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(rows as List);
  }

  @override
  Stream<List<Map<String, dynamic>>> watchByUserId(String userId) {
    late final StreamController<List<Map<String, dynamic>>> controller;
    RealtimeChannel? channel;

    Future<void> emitLatest() async {
      if (controller.isClosed) {
        return;
      }
      try {
        final rows = await findByUserId(userId);
        if (!controller.isClosed) {
          controller.add(rows);
        }
      } catch (error, stack) {
        if (!controller.isClosed) {
          controller.addError(error, stack);
        }
      }
    }

    controller = StreamController<List<Map<String, dynamic>>>.broadcast(
      onListen: () {
        unawaited(emitLatest());

        channel = _supabaseClient
            .channel('store_bookmarks:$userId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'store_bookmarks',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: userId,
              ),
              callback: (_) {
                unawaited(emitLatest());
              },
            )
            .subscribe();
      },
      onCancel: () async {
        if (channel != null) {
          await _supabaseClient.removeChannel(channel!);
          channel = null;
        }
        await controller.close();
      },
    );

    return controller.stream;
  }
}
