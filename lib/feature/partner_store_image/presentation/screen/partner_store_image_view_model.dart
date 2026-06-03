import 'package:capstone_2026/core/presentation/util/app_snack_bar.dart';
import 'dart:async';

import 'package:capstone_2026/core/domain/model/store/store_image.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/feature/partner_store_image/presentation/screen/partner_store_image_action.dart';
import 'package:capstone_2026/feature/partner_store_image/presentation/screen/partner_store_image_event.dart';
import 'package:capstone_2026/feature/partner_store_image/presentation/screen/partner_store_image_state.dart';
import 'package:flutter/foundation.dart';

class PartnerStoreImageViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;

  PartnerStoreImageViewModel({
    required StoreRepository storeRepository,
  }) : _storeRepository = storeRepository;

  PartnerStoreImageState _state = const PartnerStoreImageState();
  PartnerStoreImageState get state => _state;

  final StreamController<PartnerStoreImageEvent> _eventController =
      StreamController<PartnerStoreImageEvent>.broadcast();
  Stream<PartnerStoreImageEvent> get eventStream => _eventController.stream;

  void onAction(PartnerStoreImageAction action) {
    switch (action) {
      case TapAddImageFromGallery():
        _eventController.add(const PartnerStoreImageEvent.openGallery());
        break;
      case RemoveStoreImage():
        _removeStoreImage(action.index);
        break;
      case ChangeStoreImageCaption():
        _changeStoreImageCaption(action.index, action.value);
        break;
      case SelectCoverImage():
        _selectCoverImage(action.index);
        break;
      case TapSave():
        save();
        break;
    }
  }

  Future<void> initialize() async {
    if (_state.isLoading) {
      return;
    }
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    try {
      final images = await _storeRepository.getMyStoreImages();
      final normalized = _withReindexedImages(images);
      _state = _state.copyWith(
        images: normalized,
        localImagePaths: List<String?>.filled(normalized.length, null),
      );
    } catch (_) {
      _eventController.add(
        const PartnerStoreImageEvent.showMessage('사진 목록을 불러오지 못했습니다.'),
      );
    } finally {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  void _removeStoreImage(int index) {
    if (index < 0 || index >= _state.images.length) {
      return;
    }
    final next = List<StoreImage>.from(_state.images)..removeAt(index);
    final nextLocalPaths = List<String?>.from(_state.localImagePaths);
    if (index < nextLocalPaths.length) {
      nextLocalPaths.removeAt(index);
    }
    _state = _state.copyWith(
      images: _withReindexedImages(next),
      localImagePaths: nextLocalPaths,
    );
    notifyListeners();
  }

  void _changeStoreImageCaption(int index, String value) {
    _updateImageAt(index, (image) => image.copyWith(caption: value));
  }

  void _selectCoverImage(int index) {
    if (index < 0 || index >= _state.images.length) {
      return;
    }
    _state = _state.copyWith(
      images: _withReindexedImages(
        List<StoreImage>.generate(
          _state.images.length,
          (i) => _state.images[i].copyWith(isCover: i == index),
        ),
      ),
    );
    notifyListeners();
  }

  Future<void> addImageByFilePath(String filePath) async {
    _state = _state.copyWith(
      images: [
        ..._state.images,
        StoreImage(
          imageUrl: '',
          sortOrder: _state.images.length,
          isCover: _state.images.isEmpty,
        ),
      ],
      localImagePaths: [..._state.localImagePaths, filePath],
    );
    notifyListeners();
  }

  Future<void> save() async {
    _state = _state.copyWith(isSaving: true);
    notifyListeners();
    try {
      final nextImages = _withReindexedImages(_state.images);
      final nextLocalPaths = List<String?>.from(_state.localImagePaths);

      for (var i = 0; i < nextImages.length; i++) {
        final localPath = i < nextLocalPaths.length ? nextLocalPaths[i] : null;
        if (localPath == null || localPath.isEmpty) {
          continue;
        }
        final uploadedUrl = await _storeRepository.uploadMyStoreImageFile(
          localPath,
        );
        nextImages[i] = nextImages[i].copyWith(imageUrl: uploadedUrl);
      }

      await _storeRepository.syncMyStoreImages(nextImages);
      _state = _state.copyWith(
        images: nextImages,
        localImagePaths: List<String?>.filled(nextImages.length, null),
      );
      _eventController.add(
        const PartnerStoreImageEvent.showMessage('사진이 저장되었습니다.', variant: AppSnackBarVariant.success),
      );
      _eventController.add(const PartnerStoreImageEvent.pop());
    } catch (e) {
      _eventController.add(PartnerStoreImageEvent.showMessage(e.toString()));
    } finally {
      _state = _state.copyWith(isSaving: false);
      notifyListeners();
    }
  }

  void _updateImageAt(
    int index,
    StoreImage Function(StoreImage current) update,
  ) {
    if (index < 0 || index >= _state.images.length) {
      return;
    }
    final next = List<StoreImage>.from(_state.images);
    next[index] = update(next[index]);
    _state = _state.copyWith(images: _withReindexedImages(next));
    notifyListeners();
  }

  List<StoreImage> _withReindexedImages(List<StoreImage> images) {
    return List<StoreImage>.generate(
      images.length,
      (index) => images[index].copyWith(sortOrder: index),
    );
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
