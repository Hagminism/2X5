import 'dart:async';

import 'package:capstone_2026/core/domain/model/enum/store_category.dart';
import 'package:capstone_2026/core/domain/repository/salon/salon_repository.dart';
import 'package:capstone_2026/core/routing/routes.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/feature/information/presentation/screen/information_action.dart';
import 'package:capstone_2026/feature/information/presentation/screen/information_event.dart';
import 'package:capstone_2026/feature/information/presentation/screen/information_state.dart';
import 'package:flutter/material.dart';

class InformationViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;
  final SalonRepository _salonRepository;

  InformationViewModel({
    required StoreRepository storeRepository,
    required SalonRepository salonRepository,
  }) : _storeRepository = storeRepository,
       _salonRepository = salonRepository;

  InformationState _state = const InformationState();

  InformationState get state => _state;

  final StreamController<InformationEvent> _eventController =
      StreamController<InformationEvent>.broadcast();

  Stream<InformationEvent> get eventStream => _eventController.stream;

  Future<void> initialize(String storeId) async {
    final store = await _storeRepository.getStoreById(storeId);
    if (store == null) {
      _eventController.add(
        const InformationEvent.showSnackBar('업장 정보를 불러오지 못했습니다.'),
      );
      return;
    }

    _state = _state.copyWith(
      storeId: store.id,
      name: store.name,
      subtitle:
          '${StoreCategory.fromDbValue(store.category)?.displayName ?? store.category} · ${store.address}',
      rating: store.rating,
      category: store.category,
    );
    if (StoreCategory.fromDbValue(store.category) == StoreCategory.salon) {
      final designers = (await _salonRepository.getDesignersByStoreId(store.id))
          .where((designer) => designer.isActive && !designer.isDeleted)
          .toList();
      _state = _state.copyWith(salonDesigners: designers);
    }
    notifyListeners();
  }

  void onAction(InformationAction action) {
    switch (action) {
      case TapInformationBack():
        _eventController.add(const InformationEvent.pop());
        break;
      case TapInformationShare():
        _eventController.add(
          const InformationEvent.showSnackBar('공유 기능은 준비 중입니다.'),
        );
        break;
      case TapInformationBookmark():
        final isBookmarked = !_state.isBookmarked;
        _state = _state.copyWith(isBookmarked: isBookmarked);
        notifyListeners();
        _eventController.add(
          InformationEvent.showSnackBar(
            isBookmarked ? '즐겨찾기에 추가했습니다.' : '즐겨찾기를 해제했습니다.',
          ),
        );
        break;
      case TapInformationReservation():
        final category = StoreCategory.fromDbValue(_state.category);
        final target = switch (category) {
          StoreCategory.studyCafe => Routes.seat,
          StoreCategory.salon => Routes.salonReservation,
          _ => Routes.reservation,
        };
        _eventController.add(
          InformationEvent.push('${action.currentLocation}/$target'),
        );
        break;
      case TapSalonDesignerReservation(
        :final currentLocation,
        :final designerId,
      ):
        final uri = Uri(
          path: '$currentLocation/${Routes.salonReservation}',
          queryParameters: {'designerId': designerId},
        );
        _eventController.add(InformationEvent.push(uri.toString()));
        break;
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
