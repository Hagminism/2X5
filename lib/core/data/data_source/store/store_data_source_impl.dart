import 'dart:io';

import 'package:capstone_2026/core/data/data_source/store/store_data_source.dart';
import 'package:capstone_2026/core/data/dto/store/store_dto.dart';
import 'package:capstone_2026/core/domain/model/store/store_image.dart';
import 'package:capstone_2026/core/domain/model/store/store_menu.dart';
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

  @override
  Future<List<StoreMenu>> findMenusByStoreId(String storeId) async {
    final jsonList = await _supabaseClient
        .from('store_menus')
        .select()
        .eq('store_id', storeId)
        .order('sort_order', ascending: true);

    return jsonList
        .map(
          (json) => StoreMenu(
            id: json['id'] as String?,
            name: (json['name'] ?? '') as String,
            price: (json['price'] as num?)?.toInt() ?? 0,
            description: (json['description'] ?? '') as String,
            imageUrl: (json['image_url'] ?? '') as String,
            sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
            isAvailable: (json['is_available'] as bool?) ?? true,
          ),
        )
        .toList();
  }

  @override
  Future<List<StoreImage>> findImagesByStoreId(String storeId) async {
    final jsonList = await _supabaseClient
        .from('store_images')
        .select()
        .eq('store_id', storeId)
        .order('is_cover', ascending: false)
        .order('sort_order', ascending: true);

    return jsonList
        .map(
          (json) => StoreImage(
            id: json['id'] as String?,
            imageUrl: (json['image_url'] ?? '') as String,
            caption: (json['caption'] ?? '') as String,
            sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
            isCover: (json['is_cover'] as bool?) ?? false,
          ),
        )
        .toList();
  }

  @override
  Future<StoreMenu> createMenu(String storeId, StoreMenu menu) async {
    final payload = <String, dynamic>{
      'store_id': storeId,
      'name': menu.name,
      'price': menu.price,
      'description': menu.description,
      'image_url': menu.imageUrl.isEmpty ? null : menu.imageUrl,
      'sort_order': menu.sortOrder,
      'is_available': menu.isAvailable,
    };

    final json = await _supabaseClient
        .from('store_menus')
        .insert(payload)
        .select()
        .single();

    return StoreMenu(
      id: json['id'] as String?,
      name: (json['name'] ?? '') as String,
      price: (json['price'] as num?)?.toInt() ?? 0,
      description: (json['description'] ?? '') as String,
      imageUrl: (json['image_url'] ?? '') as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isAvailable: (json['is_available'] as bool?) ?? true,
    );
  }

  @override
  Future<StoreImage> createImage(String storeId, StoreImage image) async {
    final payload = <String, dynamic>{
      'store_id': storeId,
      'image_url': image.imageUrl,
      'caption': image.caption.isEmpty ? null : image.caption,
      'sort_order': image.sortOrder,
      'is_cover': image.isCover,
    };

    final json = await _supabaseClient
        .from('store_images')
        .insert(payload)
        .select()
        .single();

    return StoreImage(
      id: json['id'] as String?,
      imageUrl: (json['image_url'] ?? '') as String,
      caption: (json['caption'] ?? '') as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isCover: (json['is_cover'] as bool?) ?? false,
    );
  }

  @override
  Future<StoreMenu> updateMenuById(String id, StoreMenu menu) async {
    final payload = <String, dynamic>{
      'name': menu.name,
      'price': menu.price,
      'description': menu.description,
      'image_url': menu.imageUrl.isEmpty ? null : menu.imageUrl,
      'sort_order': menu.sortOrder,
      'is_available': menu.isAvailable,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final json = await _supabaseClient
        .from('store_menus')
        .update(payload)
        .eq('id', id)
        .select()
        .single();

    return StoreMenu(
      id: json['id'] as String?,
      name: (json['name'] ?? '') as String,
      price: (json['price'] as num?)?.toInt() ?? 0,
      description: (json['description'] ?? '') as String,
      imageUrl: (json['image_url'] ?? '') as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isAvailable: (json['is_available'] as bool?) ?? true,
    );
  }

  @override
  Future<StoreImage> updateImageById(String id, StoreImage image) async {
    final payload = <String, dynamic>{
      'image_url': image.imageUrl,
      'caption': image.caption.isEmpty ? null : image.caption,
      'sort_order': image.sortOrder,
      'is_cover': image.isCover,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final json = await _supabaseClient
        .from('store_images')
        .update(payload)
        .eq('id', id)
        .select()
        .single();

    return StoreImage(
      id: json['id'] as String?,
      imageUrl: (json['image_url'] ?? '') as String,
      caption: (json['caption'] ?? '') as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isCover: (json['is_cover'] as bool?) ?? false,
    );
  }

  @override
  Future<void> deleteMenusByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return;
    }
    await _supabaseClient.from('store_menus').delete().inFilter('id', ids);
  }

  @override
  Future<void> deleteImagesByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return;
    }
    await _supabaseClient.from('store_images').delete().inFilter('id', ids);
  }

  @override
  Future<String> uploadImageFile({
    required String storeId,
    required String filePath,
  }) async {
    final file = File(filePath);
    final extension = filePath.contains('.') ? filePath.split('.').last : 'jpg';
    final objectPath =
        '$storeId/${DateTime.now().millisecondsSinceEpoch}.$extension';

    await _supabaseClient.storage.from('store-images').upload(
      objectPath,
      file,
      fileOptions: const FileOptions(upsert: true),
    );

    return _supabaseClient.storage.from('store-images').getPublicUrl(objectPath);
  }
}
