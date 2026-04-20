import 'dart:async';

import 'package:capstone_2026/feature/store_detail/data/mocks/store_detail_mock_data.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_action.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_event.dart';
import 'package:capstone_2026/feature/store_detail/presentation/screen/store_detail_state.dart';
import 'package:flutter/material.dart';

class StoreDetailViewModel extends ChangeNotifier {
  StoreDetailState _state = const StoreDetailState();

  StoreDetailState get state => _state;

  final StreamController<StoreDetailEvent> _eventController =
      StreamController<StoreDetailEvent>();

  Stream<StoreDetailEvent> get eventStream => _eventController.stream;

  void onAction(StoreDetailAction action) {
    switch (action) {
      case Initialize():
        _initialize(action.storeId);
        break;
      case TapTab():
        _tapTab(action.index);
        break;
      case TapBack():
        _eventController.add(const StoreDetailEvent.moveBack());
        break;
      case TapHome():
        _eventController.add(const StoreDetailEvent.moveHome());
        break;
      case TapSearch():
        _eventController.add(const StoreDetailEvent.showMessage('검색 기능은 준비 중입니다.'));
        break;
      case TapTopBookmark():
      case TapBottomBookmark():
        _eventController.add(const StoreDetailEvent.showMessage('저장 기능은 준비 중입니다.'));
        break;
      case TapShare():
        _eventController.add(const StoreDetailEvent.showMessage('공유 기능은 준비 중입니다.'));
        break;
      case TapInfoCall():
      case TapBottomCall():
        _eventController.add(const StoreDetailEvent.showMessage('전화 연결 기능은 준비 중입니다.'));
        break;
      case TapReserve():
        _eventController.add(
          const StoreDetailEvent.showMessage('예약 바텀시트는 다음 단계에서 연결됩니다.'),
        );
        break;
    }
  }

  void _initialize(String storeId) {
    _state = state.copyWith(
      storeId: storeId,
      selectedTab: 0,
      data: storeData[storeId] ?? defaultStoreData,
    );
    notifyListeners();
  }

  void _tapTab(int index) {
    if (state.selectedTab == index) return;

    _state = state.copyWith(selectedTab: index);
    notifyListeners();
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
