import 'dart:async';

import 'package:capstone_2026/feature/store_detail/domain/repository/store_detail_repository.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_action.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_event.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_state.dart';
import 'package:flutter/material.dart';

class StoreDetailViewModel extends ChangeNotifier {
  final StoreDetailRepository _storeDetailRepository;

  StoreDetailViewModel({
    required StoreDetailRepository storeDetailRepository,
  }) : _storeDetailRepository = storeDetailRepository;

  StoreDetailState _state = const StoreDetailState();

  StoreDetailState get state => _state;

  final StreamController<StoreDetailEvent> _eventController =
      StreamController<StoreDetailEvent>();

  Stream<StoreDetailEvent> get eventStream => _eventController.stream;

  void initialize(String storeId) {
    _state = state.copyWith(
      selectedTab: 0,
      data: _storeDetailRepository.getStoreDetailById(storeId),
    );
    notifyListeners();
  }

  void onAction(StoreDetailAction action) {
    switch (action) {
      case TapBack():
      case TapHome():
        break;
      case MoveTab():
        _moveTab(action.index);
        break;
      case TapSearch():
        _showSoonMessage('검색 기능은 준비 중입니다.');
        break;
      case TapBookmark():
        _showSoonMessage('저장 기능은 준비 중입니다.');
        break;
      case TapShare():
        _showSoonMessage('공유 기능은 준비 중입니다.');
        break;
      case TapCall():
        _showSoonMessage('전화 연결 기능은 준비 중입니다.');
        break;
      case TapReserve():
        _showSoonMessage('예약 바텀시트는 다음 단계에서 연결됩니다.');
        break;
    }
  }

  void _moveTab(int index) {
    if (state.selectedTab == index) return;

    _state = state.copyWith(selectedTab: index);
    notifyListeners();
  }

  void _showSoonMessage(String message) {
    _eventController.add(StoreDetailEvent.showMessage(message));
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
