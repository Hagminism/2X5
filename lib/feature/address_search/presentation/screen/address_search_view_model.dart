import 'dart:async';

import 'package:capstone_2026/feature/address_search/data/data_source/address_search_data_source.dart';
import 'package:capstone_2026/feature/address_search/domain/model/address_search_result.dart';
import 'package:capstone_2026/feature/address_search/presentation/screen/address_search_action.dart';
import 'package:capstone_2026/feature/address_search/presentation/screen/address_search_event.dart';
import 'package:capstone_2026/feature/address_search/presentation/screen/address_search_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AddressSearchViewModel extends ChangeNotifier {
  final AddressSearchDataSource _addressSearchDataSource;

  AddressSearchViewModel({
    required AddressSearchDataSource addressSearchDataSource,
  }) : _addressSearchDataSource = addressSearchDataSource;

  AddressSearchState _state = const AddressSearchState();

  AddressSearchState get state => _state;

  final StreamController<AddressSearchEvent> _eventController =
      StreamController<AddressSearchEvent>.broadcast();

  Stream<AddressSearchEvent> get eventStream => _eventController.stream;

  Future<void> onAction(AddressSearchAction action) async {
    switch (action) {
      case ChangeQuery():
        _state = state.copyWith(query: action.query);
        notifyListeners();
        break;
      case TapSearch():
        await _search();
        break;
      case SelectResult():
        debugPrint(
          '[AddressFlow] selected item address=${action.item.address}, '
          'lat=${action.item.latitude}, lng=${action.item.longitude}',
        );
        _eventController.add(
          AddressSearchEvent.popWithResult(
            AddressSearchResult(
              address: action.item.address,
              latitude: action.item.latitude,
              longitude: action.item.longitude,
            ),
          ),
        );
        break;
    }
  }

  Future<void> _search() async {
    if (state.query.trim().isEmpty) {
      _eventController.add(
        const AddressSearchEvent.showMessage('검색어를 입력해 주세요.'),
      );
      return;
    }

    _state = state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final results = await _addressSearchDataSource.searchAddresses(
        state.query,
      );
      _state = state.copyWith(isLoading: false, results: results);
      notifyListeners();
      if (results.isEmpty) {
        _eventController.add(
          const AddressSearchEvent.showMessage('검색 결과가 없습니다.'),
        );
      }
    } catch (e) {
      _state = state.copyWith(isLoading: false);
      notifyListeners();
      _eventController.add(
        AddressSearchEvent.showMessage(
          e is StateError ? e.message : '주소 검색 중 오류가 발생했습니다.',
        ),
      );
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
