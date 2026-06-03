import 'dart:convert';
import 'dart:io';

import 'package:capstone_2026/core/data/data_source/review/review_image_data_source.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
class ReviewImageUploadException implements Exception {
  const ReviewImageUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ReviewImageDataSourceImpl implements ReviewImageDataSource {
  ReviewImageDataSourceImpl({
    required FirebaseFunctions firebaseFunctions,
  }) : _firebaseFunctions = firebaseFunctions;

  static const int _maxImageCount = 3;
  static const int _maxImageBytes = 5 * 1024 * 1024;

  final FirebaseFunctions _firebaseFunctions;

  @override
  Future<List<String>> uploadReviewImages({
    required String userId,
    required List<String> filePaths,
  }) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      throw const ReviewImageUploadException('로그인이 필요합니다.');
    }

    final localPaths = filePaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toList();
    if (localPaths.length > _maxImageCount) {
      throw const ReviewImageUploadException(
        '리뷰 사진은 최대 3장까지 등록할 수 있습니다.',
      );
    }
    if (localPaths.isEmpty) {
      return const [];
    }

    final uploadedUrls = <String>[];
    try {
      for (var index = 0; index < localPaths.length; index++) {
        final publicUrl = await _uploadSingle(
          filePath: localPaths[index],
          index: index,
        );
        uploadedUrls.add(publicUrl);
      }
      return uploadedUrls;
    } catch (error) {
      await deleteReviewImagesByPublicUrls(publicUrls: uploadedUrls);
      if (error is ReviewImageUploadException) {
        rethrow;
      }
      debugPrint('[ReviewImageDataSource] upload failed: $error');
      throw const ReviewImageUploadException(
        '리뷰 사진 업로드에 실패했습니다. 잠시 후 다시 시도해 주세요.',
      );
    }
  }

  Future<String> _uploadSingle({
    required String filePath,
    required int index,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const ReviewImageUploadException('선택한 사진을 찾을 수 없습니다.');
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw const ReviewImageUploadException('비어 있는 사진은 업로드할 수 없습니다.');
    }
    if (bytes.length > _maxImageBytes) {
      throw const ReviewImageUploadException(
        '리뷰 사진은 장당 5MB 이하만 업로드할 수 있습니다.',
      );
    }

    final extension = _resolveExtension(filePath);
    final callable = _firebaseFunctions.httpsCallable(
      'uploadReviewImageToSupabase',
    );
    final response = await callable.call({
      'fileBase64': base64Encode(bytes),
      'fileExtension': extension,
      'contentType': _contentTypeForExtension(extension),
    });

    final data = response.data;
    if (data is Map && data['publicUrl'] is String) {
      final publicUrl = (data['publicUrl'] as String).trim();
      if (publicUrl.isNotEmpty) {
        return publicUrl;
      }
    }

    throw const ReviewImageUploadException(
      '리뷰 사진 업로드에 실패했습니다. 잠시 후 다시 시도해 주세요.',
    );
  }

  @override
  Future<void> deleteReviewImagesByPublicUrls({
    required List<String> publicUrls,
  }) async {
    final objectPaths = publicUrls
        .map((url) => _extractObjectPath(publicUrl: url))
        .whereType<String>()
        .toList();
    if (objectPaths.isEmpty) {
      return;
    }

    final callable = _firebaseFunctions.httpsCallable(
      'deleteReviewImageFromSupabase',
    );

    for (final objectPath in objectPaths) {
      try {
        await callable.call({
          'objectPath': objectPath,
        });
      } catch (error) {
        debugPrint(
          '[ReviewImageDataSource] rollback delete failed: $objectPath $error',
        );
      }
    }
  }

  String? _extractObjectPath({required String publicUrl}) {
    const bucketId = 'review_images';
    final trimmed = publicUrl.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final marker = '/storage/v1/object/public/$bucketId/';
    final markerIndex = trimmed.indexOf(marker);
    if (markerIndex < 0) {
      return null;
    }

    return Uri.decodeComponent(
      trimmed.substring(markerIndex + marker.length),
    );
  }

  String _resolveExtension(String filePath) {
    final extension = filePath.contains('.')
        ? filePath.split('.').last.toLowerCase()
        : 'jpg';

    switch (extension) {
      case 'png':
      case 'webp':
      case 'jpeg':
      case 'jpg':
        return extension == 'jpeg' ? 'jpg' : extension;
      default:
        throw const ReviewImageUploadException(
          'jpg, png, webp 형식의 사진만 업로드할 수 있습니다.',
        );
    }
  }

  String _contentTypeForExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }
}
