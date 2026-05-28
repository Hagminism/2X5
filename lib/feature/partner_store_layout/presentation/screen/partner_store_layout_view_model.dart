import 'dart:async';
import 'dart:math' as math;

import 'package:capstone_2026/core/domain/model/store/store_layout_detail.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element_type.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:capstone_2026/core/domain/repository/store/store_repository.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/layout/domain/model/partner_studycafe_layout_item_type.dart';
import 'package:capstone_2026/feature/partner_studycafe_layout/layout/domain/model/partner_studycafe_layout_selected_layout_item.dart';
import 'package:capstone_2026/feature/partner_store_layout/presentation/screen/partner_store_layout_action.dart';
import 'package:capstone_2026/feature/partner_store_layout/presentation/screen/partner_store_layout_event.dart';
import 'package:capstone_2026/feature/partner_store_layout/presentation/screen/partner_store_layout_state.dart';
import 'package:flutter/foundation.dart';

class PartnerStoreLayoutViewModel extends ChangeNotifier {
  final StoreRepository _storeRepository;

  PartnerStoreLayoutViewModel({
    required StoreRepository storeRepository,
  }) : _storeRepository = storeRepository;

  PartnerStoreLayoutState _state = const PartnerStoreLayoutState();

  PartnerStoreLayoutState get state => _state;

  final StreamController<PartnerStoreLayoutEvent> _eventController =
      StreamController<PartnerStoreLayoutEvent>.broadcast();

  Stream<PartnerStoreLayoutEvent> get eventStream => _eventController.stream;

  Future<void> initialize() async {
    _state = state.copyWith(isLoading: true);
    notifyListeners();
    try {
      final myStore = await _storeRepository.getMyStore();
      if (myStore == null) {
        throw StateError('등록된 업장 정보가 없습니다.');
      }
      final layout = await _storeRepository.getStoreLayoutByStoreId(myStore.id);

      _state = state.copyWith(
        isLoading: false,
        detailId: layout?.id ?? '',
        storeId: myStore.id,
        seats: layout?.seats ?? const [],
        elements: layout?.elements ?? const [],
      );
      notifyListeners();
    } catch (e) {
      _state = state.copyWith(isLoading: false);
      notifyListeners();
      _eventController.add(
        PartnerStoreLayoutEvent.showMessage(e.toString()),
      );
    }
  }

  void onAction(PartnerStoreLayoutAction action) {
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
      case DuplicateSelectedSeats():
        _duplicateSelectedSeats();
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
    _state = state.copyWith(isSaving: true);
    notifyListeners();
    try {
      final layout = StoreLayoutDetail(
        id: state.detailId,
        storeId: state.storeId,
        seats: state.seats,
        elements: state.elements,
      );
      final saved = await _storeRepository.saveMyStoreLayout(layout);
      _state = state.copyWith(
        isSaving: false,
        detailId: saved.id,
        storeId: saved.storeId,
        seats: saved.seats,
        elements: saved.elements,
      );
      notifyListeners();
      _eventController.add(
        const PartnerStoreLayoutEvent.showMessage('내부 구조 배치가 저장되었습니다.'),
      );
    } catch (e) {
      _state = state.copyWith(isSaving: false);
      notifyListeners();
      _eventController.add(
        PartnerStoreLayoutEvent.showMessage(e.toString()),
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

  void _duplicateSelectedSeats() {
    final selectedIds = state.selectedSeatIds.toSet();
    if (selectedIds.isEmpty) {
      _eventController.add(
        const PartnerStoreLayoutEvent.showMessage('복사할 좌석을 선택해 주세요.'),
      );
      return;
    }
    final selected = state.seats
        .where((StudyCafeSeat s) => selectedIds.contains(s.seatId))
        .toList();
    if (selected.isEmpty) {
      return;
    }
    final xs = selected.map((StudyCafeSeat s) => s.x).toList();
    final ys = selected.map((StudyCafeSeat s) => s.y).toList();

    const candidates = <List<double>>[
      [0.06, 0.06],
      [-0.06, 0.06],
      [0.06, -0.06],
      [-0.06, -0.06],
      [0.08, 0],
      [-0.08, 0],
      [0, 0.08],
      [0, -0.08],
      [0.04, 0.04],
      [-0.04, -0.04],
    ];
    double? dx;
    double? dy;
    for (final List<double> pair in candidates) {
      final double cdx = _clampGroupAxisDelta(xs, pair[0]);
      final double cdy = _clampGroupAxisDelta(ys, pair[1]);
      if (cdx != 0 || cdy != 0) {
        dx = cdx;
        dy = cdy;
        break;
      }
    }
    if (dx == null || dy == null) {
      _eventController.add(
        const PartnerStoreLayoutEvent.showMessage(
          '캔버스 안에 복사본을 놓을 공간이 없습니다.',
        ),
      );
      return;
    }
    final double useDx = dx;
    final double useDy = dy;

    var idCounter = _maxSeatNumericSuffixFromIds() + 1;
    var labelCounter = _nextSeatNumber();
    final newSeats = <StudyCafeSeat>[];
    final newSeatIds = <String>[];
    for (final StudyCafeSeat s in selected) {
      final newId = 'seat_$idCounter';
      idCounter++;
      newSeatIds.add(newId);
      newSeats.add(
        s.copyWith(
          seatId: newId,
          label: '$labelCounter',
          x: s.x + useDx,
          y: s.y + useDy,
        ),
      );
      labelCounter++;
    }
    _state = state.copyWith(
      seats: [...state.seats, ...newSeats],
      selectedSeatIds: newSeatIds,
      selectedElementIds: const [],
      selectedElementId: null,
    );
    notifyListeners();
    _eventController.add(
      PartnerStoreLayoutEvent.showMessage(
        '${newSeats.length}개 테이블을 복사했습니다.',
      ),
    );
  }

  int _maxSeatNumericSuffixFromIds() {
    var maxV = 0;
    for (final StudyCafeSeat s in state.seats) {
      final String id = s.seatId;
      if (!id.startsWith('seat_')) {
        continue;
      }
      final String tail = id.substring(5);
      final int? v = int.tryParse(tail);
      if (v != null && v > maxV) {
        maxV = v;
      }
    }
    return maxV;
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
    final inSeatSelection = state.selectedSeatIds.contains(seatId);
    final seatIds = inSeatSelection ? state.selectedSeatIds.toSet() : {seatId};
    final elementIds = inSeatSelection && state.selectedElementIds.isNotEmpty
        ? state.selectedElementIds.toSet()
        : <String>{};
    _applyRigidTranslation(
      seatIds: seatIds,
      elementIds: elementIds,
      deltaX: deltaX,
      deltaY: deltaY,
      adhoc: inSeatSelection ? _SelectionAdhoc.none : _SelectionAdhoc.seat,
      primarySeatId: seatId,
    );
  }

  void _moveElement({
    required String elementId,
    required double deltaX,
    required double deltaY,
  }) {
    final inElementSelection = state.selectedElementIds.contains(elementId);
    final elementIds = inElementSelection
        ? state.selectedElementIds.toSet()
        : {elementId};
    final seatIds = inElementSelection && state.selectedSeatIds.isNotEmpty
        ? state.selectedSeatIds.toSet()
        : <String>{};
    _applyRigidTranslation(
      seatIds: seatIds,
      elementIds: elementIds,
      deltaX: deltaX,
      deltaY: deltaY,
      adhoc: inElementSelection
          ? _SelectionAdhoc.none
          : _SelectionAdhoc.element,
      primaryElementId: elementId,
    );
  }

  void _applyRigidTranslation({
    required Set<String> seatIds,
    required Set<String> elementIds,
    required double deltaX,
    required double deltaY,
    required _SelectionAdhoc adhoc,
    String? primarySeatId,
    String? primaryElementId,
  }) {
    if (seatIds.isEmpty && elementIds.isEmpty) {
      return;
    }
    final xs = <double>[];
    final ys = <double>[];
    for (final seat in state.seats) {
      if (seatIds.contains(seat.seatId)) {
        xs.add(seat.x);
        ys.add(seat.y);
      }
    }
    for (final element in state.elements) {
      if (elementIds.contains(element.elementId)) {
        xs.add(element.x);
        ys.add(element.y);
      }
    }
    if (xs.isEmpty && ys.isEmpty) {
      return;
    }
    final dx = _clampGroupAxisDelta(xs, deltaX);
    final dy = _clampGroupAxisDelta(ys, deltaY);
    if (dx == 0 && dy == 0) {
      return;
    }
    final nextSeats = state.seats.map((seat) {
      if (!seatIds.contains(seat.seatId)) {
        return seat;
      }
      return seat.copyWith(
        x: seat.x + dx,
        y: seat.y + dy,
      );
    }).toList();
    final nextElements = state.elements.map((element) {
      if (!elementIds.contains(element.elementId)) {
        return element;
      }
      return element.copyWith(
        x: element.x + dx,
        y: element.y + dy,
      );
    }).toList();

    final List<String> nextSelectedSeatIds;
    final List<String> nextSelectedElementIds;
    final String? nextSelectedElementId;
    switch (adhoc) {
      case _SelectionAdhoc.none:
        nextSelectedSeatIds = state.selectedSeatIds;
        nextSelectedElementIds = state.selectedElementIds;
        nextSelectedElementId = state.selectedElementId;
        break;
      case _SelectionAdhoc.seat:
        nextSelectedSeatIds = [primarySeatId!];
        nextSelectedElementIds = const [];
        nextSelectedElementId = null;
        break;
      case _SelectionAdhoc.element:
        nextSelectedSeatIds = const [];
        nextSelectedElementIds = [primaryElementId!];
        nextSelectedElementId = primaryElementId;
        break;
    }

    _state = state.copyWith(
      seats: nextSeats,
      elements: nextElements,
      selectedSeatIds: nextSelectedSeatIds,
      selectedElementIds: nextSelectedElementIds,
      selectedElementId: nextSelectedElementId,
    );
    notifyListeners();
  }

  double _clampGroupAxisDelta(List<double> origins, double delta) {
    if (origins.isEmpty || delta == 0) {
      return 0;
    }
    if (delta > 0) {
      final cap = origins.map((double v) => 1 - v).reduce(math.min);
      return math.min(delta, cap);
    }
    final floor = origins.map((double v) => -v).reduce(math.max);
    return math.max(delta, floor);
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

enum _SelectionAdhoc { none, seat, element }
