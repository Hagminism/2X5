import 'package:flutter/material.dart';
import '../../domain/repository/reservation_repository.dart';

class ReservationViewModel extends ChangeNotifier {
  final ReservationRepository _repository;
  bool _isLoading = false;

  ReservationViewModel(this._repository);

  bool get isLoading => _isLoading;

  Future<bool> submitReservation({
    required DateTime? selectedDay,
    required String? selectedTime,
    required int guestCount,
  }) async {
    if (selectedDay == null || selectedTime == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _repository.createReservation(
        date: selectedDay.toIso8601String().split('T')[0],
        time: selectedTime,
        guestCount: guestCount,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
