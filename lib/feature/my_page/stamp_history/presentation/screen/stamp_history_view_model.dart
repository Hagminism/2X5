import 'package:capstone_2026/feature/my_page/stamp_history/presentation/screen/stamp_history_state.dart';
import 'package:capstone_2026/feature/stamp/domain/service/stamp_service.dart';
import 'package:flutter/material.dart';

class StampHistoryViewModel extends ChangeNotifier {
  StampHistoryViewModel({
    required StampService stampService,
  }) : _stampService = stampService;

  final StampService _stampService;

  StampHistoryState _state = const StampHistoryState();

  StampHistoryState get state => _state;

  Future<void> fetchStamps() async {
    if (state.isLoading) return;

    _state = state.copyWith(isLoading: true);
    notifyListeners();

    final stampStatuses = await _stampService.loadMyStampStatuses();

    _state = state.copyWith(
      isLoading: false,
      stampStatuses: stampStatuses,
    );
    notifyListeners();
  }
}
