import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/model/studycafe/studycafe_detail.dart';
import '../../../core/domain/model/studycafe/studycafe_layout_element.dart';
import '../../../core/domain/model/studycafe/studycafe_layout_element_type.dart';
import '../../../core/domain/model/studycafe/studycafe_reservation.dart';
import '../../../core/domain/model/studycafe/studycafe_seat.dart';
import '../../../core/domain/repository/studycafe/studycafe_repository.dart';
import '../../../di/di_setup.dart';
import '../../../ui/app_colors.dart';

class SeatSelectionScreen extends StatefulWidget {
  final String storeId;

  const SeatSelectionScreen({super.key, required this.storeId});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  static const double _canvasAspectRatio = 650 / 400;

  final StudyCafeRepository _studyCafeRepository = getIt<StudyCafeRepository>();

  bool _isLoading = true;
  String? _errorMessage;
  List<StudyCafeSeat> _seats = const [];
  List<StudyCafeLayoutElement> _elements = const [];
  Set<String> _occupiedSeatIds = <String>{};
  String? _selectedSeatId;
  StreamSubscription<List<StudyCafeReservation>>? _reservationSubscription;

  StudyCafeSeat? get _selectedSeat {
    final selectedSeatId = _selectedSeatId;
    if (selectedSeatId == null) {
      return null;
    }
    for (final seat in _seats) {
      if (seat.seatId == selectedSeatId) {
        return seat;
      }
    }
    return null;
  }

  String _seatLabelForDisplay(StudyCafeSeat seat) {
    final trimmed = seat.label.trim();
    return trimmed.isNotEmpty ? trimmed : seat.seatId;
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _reservationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final detail = await _studyCafeRepository.getDetailByStoreId(widget.storeId);
      final normalizedDetail = detail ?? StudyCafeDetail.empty(widget.storeId);
      final activeReservations = await _studyCafeRepository
          .getActiveReservationsByStoreId(widget.storeId);
      if (!mounted) {
        return;
      }
      setState(() {
        _seats = normalizedDetail.seats;
        _elements = normalizedDetail.elements;
        _occupiedSeatIds = activeReservations.map((e) => e.seatId).toSet();
        _isLoading = false;
      });
      _reservationSubscription?.cancel();
      _reservationSubscription = _studyCafeRepository
          .watchActiveReservationsByStoreId(widget.storeId)
          .listen((reservations) {
            if (!mounted) {
              return;
            }
            final occupiedSeatIds = reservations.map((e) => e.seatId).toSet();
            setState(() {
              _occupiedSeatIds = occupiedSeatIds;
              if (_selectedSeatId != null &&
                  occupiedSeatIds.contains(_selectedSeatId)) {
                _selectedSeatId = null;
              }
            });
          });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '좌석 선택',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatusInfo(AppColors.black, '이용가능'),
                const SizedBox(width: 16),
                _buildStatusInfo(AppColors.authProviderButton, '이용중'),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: _buildBody(),
          ),
          if (_selectedSeat != null) _buildBottomAction(context, _selectedSeat!),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _initialize,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }
    if (_seats.isEmpty) {
      return const Center(
        child: Text(
          '등록된 좌석이 없습니다.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width - 32;
          final canvasWidth = (availableWidth - 24)
              .clamp(280.0, 560.0)
              .toDouble();
          final canvasHeight = canvasWidth * _canvasAspectRatio;
          final seatSize = (canvasWidth * 0.085).clamp(30.0, 44.0).toDouble();

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: canvasWidth,
                    height: canvasHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          for (final element in _elements)
                            _buildElement(
                              element,
                              canvasWidth: canvasWidth,
                              canvasHeight: canvasHeight,
                            ),
                          for (final seat in _seats)
                            _buildSeat(
                              seat,
                              canvasWidth: canvasWidth,
                              canvasHeight: canvasHeight,
                              seatSize: seatSize,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildElement(
    StudyCafeLayoutElement element, {
    required double canvasWidth,
    required double canvasHeight,
  }) {
    final width = (canvasWidth * element.width)
        .clamp(16.0, canvasWidth)
        .toDouble();
    final height = (canvasHeight * element.height)
        .clamp(10.0, canvasHeight)
        .toDouble();
    final movableWidth = canvasWidth - width;
    final movableHeight = canvasHeight - height;
    final left = element.x.clamp(0, 1).toDouble() * movableWidth;
    final top = element.y.clamp(0, 1).toDouble() * movableHeight;

    final decoration = switch (element.type) {
      StudyCafeLayoutElementType.partition => BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
      StudyCafeLayoutElementType.door => BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(999),
        ),
      StudyCafeLayoutElementType.fixture => BoxDecoration(
          color: AppColors.surfaceMuted,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
    };

    final labelColor = switch (element.type) {
      StudyCafeLayoutElementType.door => AppColors.primary,
      StudyCafeLayoutElementType.partition => AppColors.textPrimary,
      StudyCafeLayoutElementType.fixture => AppColors.textPrimary,
    };
    final labelFontSize =
        (canvasWidth * 0.028).clamp(10.0, 13.0).toDouble();

    return Positioned(
      top: top,
      left: left,
      child: Transform.rotate(
        angle: element.rotation * 3.1415926535 / 180,
        child: Container(
          width: width,
          height: height,
          decoration: decoration,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            element.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: labelColor,
              fontSize: labelFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeat(
    StudyCafeSeat seat, {
    required double canvasWidth,
    required double canvasHeight,
    required double seatSize,
  }) {
    final movableWidth = canvasWidth - seatSize;
    final movableHeight = canvasHeight - seatSize;
    final left = seat.x.clamp(0, 1).toDouble() * movableWidth;
    final top = seat.y.clamp(0, 1).toDouble() * movableHeight;
    final isOccupied = _occupiedSeatIds.contains(seat.seatId) || !seat.isEnabled;
    final isSelected = _selectedSeatId == seat.seatId;
    final seatLabelText = _seatLabelForDisplay(seat);

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () {
          if (isOccupied) {
            return;
          }
          setState(() {
            _selectedSeatId = seat.seatId;
          });
        },
        child: Container(
          width: seatSize,
          height: seatSize,
          decoration: BoxDecoration(
            color: isOccupied
                ? AppColors.authProviderButton
                : (isSelected ? AppColors.primary : AppColors.white),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              seatLabelText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontSize: (canvasWidth * 0.03).clamp(10.0, 12.0).toDouble(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, StudyCafeSeat selectedSeat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_seatLabelForDisplay(selectedSeat)}번 좌석',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  '개방형 좌석',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 130,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final seatId = Uri.encodeComponent(selectedSeat.seatId);
                  final seatLabel = Uri.encodeComponent(
                    _seatLabelForDisplay(selectedSeat),
                  );
                  final storeId = Uri.encodeComponent(widget.storeId);
                  context.push(
                    'duration/$seatId?storeId=$storeId&seatLabel=$seatLabel',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '선택',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusInfo(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}