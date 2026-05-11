import 'dart:async';

import 'package:capstone_2026/core/domain/model/studycafe/studycafe_detail.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element_type.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_usage_option.dart';
import 'package:capstone_2026/core/domain/repository/studycafe/studycafe_repository.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/domain/model/partner_studycafe_layout_item_type.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/domain/model/partner_studycafe_layout_selected_layout_item.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/screen/partner_studycafe_layout_action.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/screen/partner_studycafe_layout_event.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/presentation/screen/partner_studycafe_layout_state.dart';
import 'package:flutter/foundation.dart';

class PartnerStudyCafeLayoutViewModel extends ChangeNotifier {
  final StudyCafeRepository _studyCafeRepository;

  PartnerStudyCafeLayoutViewModel({
    required StudyCafeRepository studyCafeRepository,
  }) : _studyCafeRepository = studyCafeRepository;

  PartnerStudyCafeLayoutState _state = const PartnerStudyCafeLayoutState();
  PartnerStudyCafeLayoutState get state => _state;

  final StreamController<PartnerStudyCafeLayoutEvent> _eventController =
      StreamController<PartnerStudyCafeLayoutEvent>.broadcast();
  Stream<PartnerStudyCafeLayoutEvent> get eventStream =>
      _eventController.stream;

  Future<void> initialize() async {
    _state = state.copyWith(isLoading: true);
    notifyListeners();
    try {
      final detail = await _studyCafeRepository.getMyStoreDetail();
      _state = state.copyWith(
        isLoading: false,
        detailId: detail.id,
        storeId: detail.storeId,
        seats: detail.seats,
        elements: detail.elements,
        usageOptions: detail.usageOptions.isEmpty
            ? const [
                StudyCafeUsageOption(
                  durationMinutes: 120,
                  price: 0,
                  isEnabled: true,
                ),
              ]
            : detail.usageOptions,
      );
      notifyListeners();
    } catch (e) {
      _state = state.copyWith(isLoading: false);
      notifyListeners();
      _eventController.add(
        PartnerStudyCafeLayoutEvent.showMessage(e.toString()),
      );
    }
  }

  void onAction(PartnerStudyCafeLayoutAction action) {
    switch (action) {
      case AddSeat():
        _addSeat();
        break;
      case AddElement():
        _addElement(action.type);
        break;
      case SelectSeat():
        _state = state.copyWith(
          selectedSeatIds: [action.seatId],
          selectedElementIds: const [],
          selectedElementId: null,
        );
        notifyListeners();
        break;
      case SelectSeats():
        _state = state.copyWith(
          selectedSeatIds: action.seatIds,
          selectedElementId: null,
        );
        notifyListeners();
        break;
      case SelectElement():
        _state = state.copyWith(
          selectedElementId: action.elementId,
          selectedElementIds: [action.elementId],
          selectedSeatIds: const [],
        );
        notifyListeners();
        break;
      case SelectElements():
        _state = state.copyWith(
          selectedElementId: action.elementIds.isEmpty
              ? null
              : action.elementIds.first,
          selectedElementIds: action.elementIds,
        );
        notifyListeners();
        break;
      case RemoveSelectedSeat():
        _removeSelectedSeat();
        break;
      case RemoveSelectedElement():
        _removeSelectedElement();
        break;
      case MoveSeat():
        _moveSeat(
          seatId: action.seatId,
          deltaX: action.deltaX,
          deltaY: action.deltaY,
        );
        break;
      case MoveElement():
        _moveElement(
          elementId: action.elementId,
          deltaX: action.deltaX,
          deltaY: action.deltaY,
        );
        break;
      case ChangeSelectedSeatLabel():
        if (state.selectedSeatIds.length == 1) {
          _updateSelectedSeats((seat) => seat.copyWith(label: action.value));
        }
        break;
      case ToggleSelectedSeatEnabled():
        _updateSelectedSeats(
          (seat) => seat.copyWith(isEnabled: action.value),
        );
        break;
      case ChangeSelectedElementLabel():
        _updateSelectedElement(
          (element) => element.copyWith(label: action.value),
        );
        break;
      case ChangeSelectedElementWidth():
        final width = (_parsePercent(action.value) / 100)
            .clamp(0.03, 1)
            .toDouble();
        _updateSelectedElement((element) => element.copyWith(width: width));
        break;
      case ChangeSelectedElementHeight():
        final height = (_parsePercent(action.value) / 100)
            .clamp(0.02, 1)
            .toDouble();
        _updateSelectedElement((element) => element.copyWith(height: height));
        break;
      case ChangeSelectedElementRotation():
        final rotation = double.tryParse(action.value.trim()) ?? 0;
        _updateSelectedElement(
          (element) => element.copyWith(rotation: rotation),
        );
        break;
      case AlignSelectedSeatsHorizontally():
        _alignSelectedItemsHorizontally();
        break;
      case AlignSelectedSeatsVertically():
        _alignSelectedItemsVertically();
        break;
      case AddUsageOption():
        _state = state.copyWith(
          usageOptions: [
            ...state.usageOptions,
            const StudyCafeUsageOption(
              durationMinutes: 120,
              price: 0,
              isEnabled: true,
            ),
          ],
        );
        notifyListeners();
        break;
      case RemoveUsageOption():
        if (action.index < 0 || action.index >= state.usageOptions.length) {
          return;
        }
        final next = List<StudyCafeUsageOption>.from(state.usageOptions)
          ..removeAt(action.index);
        _state = state.copyWith(usageOptions: next);
        notifyListeners();
        break;
      case ChangeUsageOptionDuration():
        final duration =
            int.tryParse(action.value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        _updateUsageOptionAt(
          action.index,
          (option) => option.copyWith(durationMinutes: duration),
        );
        break;
      case ChangeUsageOptionPrice():
        final price =
            int.tryParse(action.value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        _updateUsageOptionAt(
          action.index,
          (option) => option.copyWith(price: price),
        );
        break;
      case ToggleUsageOptionEnabled():
        _updateUsageOptionAt(
          action.index,
          (option) => option.copyWith(isEnabled: action.value),
        );
        break;
      case TapSave():
        save();
        break;
    }
  }

  Future<void> save() async {
    if (state.isSaving) {
      return;
    }
    final detail = StudyCafeDetail(
      id: state.detailId,
      storeId: state.storeId,
      seats: state.seats,
      elements: state.elements,
      usageOptions: state.usageOptions,
    );
    _state = state.copyWith(isSaving: true);
    notifyListeners();
    try {
      final saved = await _studyCafeRepository.saveMyStoreDetail(detail);
      _state = state.copyWith(
        isSaving: false,
        detailId: saved.id,
        storeId: saved.storeId,
        seats: saved.seats,
        elements: saved.elements,
        usageOptions: saved.usageOptions,
      );
      notifyListeners();
      _eventController.add(
        const PartnerStudyCafeLayoutEvent.showMessage('좌석 배치가 저장되었습니다.'),
      );
    } catch (e) {
      _state = state.copyWith(isSaving: false);
      notifyListeners();
      _eventController.add(
        PartnerStudyCafeLayoutEvent.showMessage(e.toString()),
      );
    }
  }

  void _addSeat() {
    final nextNumber = _nextSeatNumber();
    final seat = StudyCafeSeat(
      seatId: 'seat_$nextNumber',
      label: '$nextNumber',
      x: 0.1,
      y: 0.1,
    );
    _state = state.copyWith(
      seats: [...state.seats, seat],
      selectedSeatIds: [seat.seatId],
      selectedElementIds: const [],
      selectedElementId: null,
    );
    notifyListeners();
  }

  void _addElement(StudyCafeLayoutElementType type) {
    final nextNumber = _nextElementNumber(type);
    final element = StudyCafeLayoutElement(
      elementId: '${type.name}_$nextNumber',
      type: type,
      label: type.label,
      x: 0.1,
      y: 0.1,
      width: switch (type) {
        StudyCafeLayoutElementType.partition => 0.32,
        StudyCafeLayoutElementType.door => 0.16,
        StudyCafeLayoutElementType.fixture => 0.22,
      },
      height: switch (type) {
        StudyCafeLayoutElementType.partition => 0.025,
        StudyCafeLayoutElementType.door => 0.08,
        StudyCafeLayoutElementType.fixture => 0.1,
      },
    );
    _state = state.copyWith(
      elements: [...state.elements, element],
      selectedElementId: element.elementId,
      selectedElementIds: [element.elementId],
      selectedSeatIds: const [],
    );
    notifyListeners();
  }

  void _removeSelectedSeat() {
    final selectedSeatIds = state.selectedSeatIds.toSet();
    if (selectedSeatIds.isEmpty) {
      return;
    }
    _state = state.copyWith(
      seats: state.seats
          .where((seat) => !selectedSeatIds.contains(seat.seatId))
          .toList(),
      selectedSeatIds: const [],
    );
    notifyListeners();
  }

  void _removeSelectedElement() {
    final selectedElementIds = state.selectedElementIds.toSet();
    if (selectedElementIds.isEmpty && state.selectedElementId == null) {
      return;
    }
    final removingIds = selectedElementIds.isEmpty
        ? {state.selectedElementId!}
        : selectedElementIds;
    _state = state.copyWith(
      elements: state.elements
          .where((element) => !removingIds.contains(element.elementId))
          .toList(),
      selectedElementId: null,
      selectedElementIds: const [],
    );
    notifyListeners();
  }

  void _moveSeat({
    required String seatId,
    required double deltaX,
    required double deltaY,
  }) {
    final movingSeatIds = state.selectedSeatIds.contains(seatId)
        ? state.selectedSeatIds.toSet()
        : {seatId};
    final next = state.seats.map((seat) {
      if (!movingSeatIds.contains(seat.seatId)) {
        return seat;
      }
      return seat.copyWith(
        x: (seat.x + deltaX).clamp(0, 1).toDouble(),
        y: (seat.y + deltaY).clamp(0, 1).toDouble(),
      );
    }).toList();
    _state = state.copyWith(
      seats: next,
      selectedSeatIds: movingSeatIds.toList(),
      selectedElementId: null,
    );
    notifyListeners();
  }

  void _moveElement({
    required String elementId,
    required double deltaX,
    required double deltaY,
  }) {
    final movingElementIds = state.selectedElementIds.contains(elementId)
        ? state.selectedElementIds.toSet()
        : {elementId};
    final updates = <String, StudyCafeLayoutElement>{};
    for (final element in state.elements) {
      if (!movingElementIds.contains(element.elementId)) {
        continue;
      }
      updates[element.elementId] = element.copyWith(
        x: (element.x + deltaX).clamp(0, 1).toDouble(),
        y: (element.y + deltaY).clamp(0, 1).toDouble(),
      );
    }
    _updateElementsById(updates);
  }

  void _alignSelectedItemsHorizontally() {
    final selectedItems = _selectedLayoutItems();
    if (selectedItems.length < 2) {
      return;
    }
    final targetY =
        selectedItems.map((item) => item.y).reduce((a, b) => a + b) /
        selectedItems.length;
    final sortedByX = [...selectedItems]..sort((a, b) => a.x.compareTo(b.x));
    final minX = sortedByX.first.x;
    final maxX = sortedByX.last.x;
    final stepX = (maxX - minX) / (sortedByX.length - 1);
    final seatUpdates = <String, StudyCafeSeat>{};
    final elementUpdates = <String, StudyCafeLayoutElement>{};

    for (var index = 0; index < sortedByX.length; index++) {
      final item = sortedByX[index];
      final nextX = (minX + (stepX * index)).clamp(0, 1).toDouble();
      final nextY = targetY.clamp(0, 1).toDouble();
      switch (item.type) {
        case PartnerStudyCafeLayoutItemType.seat:
          seatUpdates[item.id] = item.seat!.copyWith(x: nextX, y: nextY);
          break;
        case PartnerStudyCafeLayoutItemType.element:
          elementUpdates[item.id] = item.element!.copyWith(x: nextX, y: nextY);
          break;
      }
    }
    _updateSelectedItems(
      seatUpdates: seatUpdates,
      elementUpdates: elementUpdates,
    );
  }

  void _alignSelectedItemsVertically() {
    final selectedItems = _selectedLayoutItems();
    if (selectedItems.length < 2) {
      return;
    }
    final targetX =
        selectedItems.map((item) => item.x).reduce((a, b) => a + b) /
        selectedItems.length;
    final sortedByY = [...selectedItems]..sort((a, b) => a.y.compareTo(b.y));
    final minY = sortedByY.first.y;
    final maxY = sortedByY.last.y;
    final stepY = (maxY - minY) / (sortedByY.length - 1);
    final seatUpdates = <String, StudyCafeSeat>{};
    final elementUpdates = <String, StudyCafeLayoutElement>{};

    for (var index = 0; index < sortedByY.length; index++) {
      final item = sortedByY[index];
      final nextY = (minY + (stepY * index)).clamp(0, 1).toDouble();
      final nextX = targetX.clamp(0, 1).toDouble();
      switch (item.type) {
        case PartnerStudyCafeLayoutItemType.seat:
          seatUpdates[item.id] = item.seat!.copyWith(x: nextX, y: nextY);
          break;
        case PartnerStudyCafeLayoutItemType.element:
          elementUpdates[item.id] = item.element!.copyWith(x: nextX, y: nextY);
          break;
      }
    }
    _updateSelectedItems(
      seatUpdates: seatUpdates,
      elementUpdates: elementUpdates,
    );
  }

  void _updateSelectedSeats(StudyCafeSeat Function(StudyCafeSeat seat) update) {
    final selectedSeatIds = state.selectedSeatIds.toSet();
    if (selectedSeatIds.isEmpty) {
      return;
    }
    final next = state.seats.map((seat) {
      if (!selectedSeatIds.contains(seat.seatId)) {
        return seat;
      }
      return update(seat);
    }).toList();
    _state = state.copyWith(seats: next);
    notifyListeners();
  }

  void _updateSelectedElement(
    StudyCafeLayoutElement Function(StudyCafeLayoutElement element) update,
  ) {
    final selectedElementId = state.selectedElementId;
    if (selectedElementId == null) {
      return;
    }
    _updateElement(selectedElementId, update);
  }

  void _updateElement(
    String elementId,
    StudyCafeLayoutElement Function(StudyCafeLayoutElement element) update,
  ) {
    final next = state.elements.map((element) {
      if (element.elementId != elementId) {
        return element;
      }
      return update(element);
    }).toList();
    _state = state.copyWith(
      elements: next,
      selectedElementId: elementId,
      selectedElementIds: [elementId],
      selectedSeatIds: const [],
    );
    notifyListeners();
  }

  void _updateElementsById(Map<String, StudyCafeLayoutElement> updates) {
    if (updates.isEmpty) {
      return;
    }
    final next = state.elements
        .map((element) => updates[element.elementId] ?? element)
        .toList();
    _state = state.copyWith(
      elements: next,
      selectedElementIds: updates.keys.toList(),
      selectedElementId: updates.keys.first,
    );
    notifyListeners();
  }

  void _updateSelectedItems({
    required Map<String, StudyCafeSeat> seatUpdates,
    required Map<String, StudyCafeLayoutElement> elementUpdates,
  }) {
    if (seatUpdates.isEmpty && elementUpdates.isEmpty) {
      return;
    }
    final nextSeats = state.seats
        .map((seat) => seatUpdates[seat.seatId] ?? seat)
        .toList();
    final nextElements = state.elements
        .map((element) => elementUpdates[element.elementId] ?? element)
        .toList();
    _state = state.copyWith(seats: nextSeats, elements: nextElements);
    notifyListeners();
  }

  void _updateUsageOptionAt(
    int index,
    StudyCafeUsageOption Function(StudyCafeUsageOption option) update,
  ) {
    if (index < 0 || index >= state.usageOptions.length) {
      return;
    }
    final next = List<StudyCafeUsageOption>.from(state.usageOptions);
    next[index] = update(next[index]);
    _state = state.copyWith(usageOptions: next);
    notifyListeners();
  }

  List<StudyCafeSeat> _selectedSeats() {
    final selectedSeatIds = state.selectedSeatIds.toSet();
    return state.seats
        .where((seat) => selectedSeatIds.contains(seat.seatId))
        .toList();
  }

  List<StudyCafeLayoutElement> _selectedElements() {
    final selectedElementIds = state.selectedElementIds.toSet();
    return state.elements
        .where((element) => selectedElementIds.contains(element.elementId))
        .toList();
  }

  List<PartnerStudyCafeLayoutSelectedLayoutItem> _selectedLayoutItems() {
    final selectedSeats = _selectedSeats()
        .map(
          (seat) => PartnerStudyCafeLayoutSelectedLayoutItem(
            id: seat.seatId,
            x: seat.x,
            y: seat.y,
            type: PartnerStudyCafeLayoutItemType.seat,
            seat: seat,
          ),
        )
        .toList();
    final selectedElements = _selectedElements()
        .map(
          (element) => PartnerStudyCafeLayoutSelectedLayoutItem(
            id: element.elementId,
            x: element.x,
            y: element.y,
            type: PartnerStudyCafeLayoutItemType.element,
            element: element,
          ),
        )
        .toList();
    return [...selectedSeats, ...selectedElements];
  }

  int _nextSeatNumber() {
    final numbers = state.seats
        .map((seat) => int.tryParse(seat.label.trim()) ?? 0)
        .toList();
    if (numbers.isEmpty) {
      return 1;
    }
    return numbers.reduce((a, b) => a > b ? a : b) + 1;
  }

  int _nextElementNumber(StudyCafeLayoutElementType type) {
    final numbers = state.elements
        .where((element) => element.type == type)
        .map((element) => int.tryParse(element.elementId.split('_').last) ?? 0)
        .toList();
    if (numbers.isEmpty) {
      return 1;
    }
    return numbers.reduce((a, b) => a > b ? a : b) + 1;
  }

  double _parsePercent(String value) {
    final normalized = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized) ?? 0;
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
