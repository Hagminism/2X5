import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_layout_element_type.dart';
import 'package:capstone_2026/core/domain/model/studycafe/studycafe_seat.dart';
import 'package:capstone_2026/ui/app_colors.dart';
import 'package:capstone_2026/ui/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'partner_studycafe_layout_action.dart';
import 'partner_studycafe_layout_state.dart';

class PartnerStudyCafeLayoutScreen extends StatelessWidget {
  final PartnerStudyCafeLayoutState state;
  final void Function(PartnerStudyCafeLayoutAction action) onAction;

  const PartnerStudyCafeLayoutScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            title: const Text('좌석 배치 관리'),
            backgroundColor: AppColors.white,
            surfaceTintColor: AppColors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              TextButton(
                onPressed: state.isSaving
                    ? null
                    : () => onAction(
                        const PartnerStudyCafeLayoutAction.tapSave(),
                      ),
                child: const Text('저장'),
              ),
            ],
          ),
          body: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        '스터디카페 좌석 배치',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '좌석은 드래그로 이동하고, 빈 공간 드래그로 여러 좌석을 선택할 수 있어요.',
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: 16),
                      _Toolbar(state: state, onAction: onAction),
                      const SizedBox(height: 16),
                      _SeatCanvas(state: state, onAction: onAction),
                      const SizedBox(height: 20),
                      _UsageOptionEditor(state: state, onAction: onAction),
                    ],
                  ),
                ),
        ),
        if (state.isSaving)
          ModalBarrier(
            dismissible: false,
            color: AppColors.black.withValues(alpha: 0.2588),
          ),
        if (state.isSaving)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  final PartnerStudyCafeLayoutState state;
  final void Function(PartnerStudyCafeLayoutAction action) onAction;

  const _Toolbar({
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _ToolbarButton(
            icon: Icons.event_seat_rounded,
            label: '좌석',
            description: '새 좌석',
            onTap: () => onAction(
              const PartnerStudyCafeLayoutAction.addSeat(),
            ),
          ),
          const SizedBox(width: 10),
          _ToolbarButton(
            icon: Icons.horizontal_rule_rounded,
            label: '파티션',
            description: '칸막이',
            onTap: () => onAction(
              const PartnerStudyCafeLayoutAction.addElement(
                StudyCafeLayoutElementType.partition,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _ToolbarButton(
            icon: Icons.door_front_door_rounded,
            label: '문',
            description: '출입구',
            onTap: () => onAction(
              const PartnerStudyCafeLayoutAction.addElement(
                StudyCafeLayoutElementType.door,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _ToolbarButton(
            icon: Icons.countertops_rounded,
            label: '구조물',
            description: '스낵바 등',
            onTap: () => onAction(
              const PartnerStudyCafeLayoutAction.addElement(
                StudyCafeLayoutElementType.fixture,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _ToolbarButton(
            icon: Icons.align_horizontal_center_rounded,
            label: '가로 정렬',
            description: '${state.selectedSeatIds.length}개 좌석',
            onTap: () => onAction(
              const PartnerStudyCafeLayoutAction.alignSelectedSeatsHorizontally(),
            ),
          ),
          const SizedBox(width: 10),
          _ToolbarButton(
            icon: Icons.align_vertical_center_rounded,
            label: '세로 정렬',
            description: '${state.selectedSeatIds.length}개 좌석',
            onTap: () => onAction(
              const PartnerStudyCafeLayoutAction.alignSelectedSeatsVertically(),
            ),
          ),
          const SizedBox(width: 10),
          _ToolbarButton(
            icon: Icons.delete_outline_rounded,
            label: '삭제',
            description: '선택 항목',
            isDanger: true,
            onTap: () {
              onAction(
                const PartnerStudyCafeLayoutAction.removeSelectedSeat(),
              );
              onAction(
                const PartnerStudyCafeLayoutAction.removeSelectedElement(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isDanger;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? AppColors.danger : AppColors.primary;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 168,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Ink(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeatCanvas extends StatefulWidget {
  final PartnerStudyCafeLayoutState state;
  final void Function(PartnerStudyCafeLayoutAction action) onAction;

  const _SeatCanvas({
    required this.state,
    required this.onAction,
  });

  @override
  State<_SeatCanvas> createState() => _SeatCanvasState();
}

class _SeatCanvasState extends State<_SeatCanvas> {
  static const double _canvasAspectRatio = 650 / 400;
  Offset? _selectionStart;
  Offset? _selectionCurrent;

  Rect? get _selectionRect {
    final start = _selectionStart;
    final current = _selectionCurrent;
    if (start == null || current == null) {
      return null;
    }
    return Rect.fromPoints(start, current);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 40;
        final canvasWidth = (availableWidth - 24)
            .clamp(280.0, 560.0)
            .toDouble();
        final canvasHeight = canvasWidth * _canvasAspectRatio;
        final seatSize = (canvasWidth * 0.085).clamp(30.0, 44.0).toDouble();

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: canvasWidth,
              height: canvasHeight,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (details) {
                  setState(() {
                    _selectionStart = details.localPosition;
                    _selectionCurrent = details.localPosition;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _selectionCurrent = details.localPosition;
                  });
                },
                onPanEnd: (_) {
                  _selectSeatsInRect(
                    canvasWidth: canvasWidth,
                    canvasHeight: canvasHeight,
                    seatSize: seatSize,
                  );
                  setState(() {
                    _selectionStart = null;
                    _selectionCurrent = null;
                  });
                },
                child: Stack(
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
                    for (final element in widget.state.elements)
                      _EditableElement(
                        element: element,
                        isSelected:
                            element.elementId == widget.state.selectedElementId,
                        canvasWidth: canvasWidth,
                        canvasHeight: canvasHeight,
                        onAction: widget.onAction,
                      ),
                    for (final seat in widget.state.seats)
                      _EditableSeat(
                        seat: seat,
                        isSelected: widget.state.selectedSeatIds.contains(
                          seat.seatId,
                        ),
                        canvasWidth: canvasWidth,
                        canvasHeight: canvasHeight,
                        seatSize: seatSize,
                        onAction: widget.onAction,
                      ),
                    if (_selectionRect case final rect?)
                      Positioned.fromRect(
                        rect: rect,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              border: Border.all(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectSeatsInRect({
    required double canvasWidth,
    required double canvasHeight,
    required double seatSize,
  }) {
    final rect = _selectionRect;
    if (rect == null || rect.shortestSide < 8) {
      return;
    }
    final movableWidth = canvasWidth - seatSize;
    final movableHeight = canvasHeight - seatSize;
    final selectedSeatIds = widget.state.seats
        .where((seat) {
          final seatRect = Rect.fromLTWH(
            seat.x.clamp(0, 1).toDouble() * movableWidth,
            seat.y.clamp(0, 1).toDouble() * movableHeight,
            seatSize,
            seatSize,
          );
          return rect.overlaps(seatRect);
        })
        .map((seat) => seat.seatId)
        .toList();

    widget.onAction(PartnerStudyCafeLayoutAction.selectSeats(selectedSeatIds));
  }
}

class _EditableElement extends StatelessWidget {
  final StudyCafeLayoutElement element;
  final bool isSelected;
  final double canvasWidth;
  final double canvasHeight;
  final void Function(PartnerStudyCafeLayoutAction action) onAction;

  const _EditableElement({
    required this.element,
    required this.isSelected,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
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
    final style = _ElementStyle.fromType(element.type, isSelected);

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () => onAction(
          PartnerStudyCafeLayoutAction.selectElement(element.elementId),
        ),
        onLongPress: () {
          onAction(
            PartnerStudyCafeLayoutAction.selectElement(element.elementId),
          );
          _showElementEditorSheet(context, element, onAction);
        },
        onPanUpdate: (details) => onAction(
          PartnerStudyCafeLayoutAction.moveElement(
            elementId: element.elementId,
            deltaX: movableWidth == 0 ? 0 : details.delta.dx / movableWidth,
            deltaY: movableHeight == 0 ? 0 : details.delta.dy / movableHeight,
          ),
        ),
        child: Transform.rotate(
          angle: element.rotation * 3.1415926535 / 180,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: style.backgroundColor,
              border: Border.all(
                color: style.borderColor,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(style.borderRadius),
            ),
            child: Center(
              child: Text(
                element.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: style.textColor,
                  fontSize: (canvasWidth * 0.028).clamp(10.0, 13.0).toDouble(),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ElementStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final double borderRadius;

  const _ElementStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.borderRadius,
  });

  factory _ElementStyle.fromType(
    StudyCafeLayoutElementType type,
    bool isSelected,
  ) {
    final selectedBorder = isSelected ? AppColors.primary : AppColors.border;
    return switch (type) {
      StudyCafeLayoutElementType.partition => _ElementStyle(
        backgroundColor: AppColors.textSecondary.withValues(alpha: 0.18),
        borderColor: selectedBorder,
        textColor: AppColors.textPrimary,
        borderRadius: 4,
      ),
      StudyCafeLayoutElementType.door => _ElementStyle(
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        borderColor: AppColors.primary,
        textColor: AppColors.primary,
        borderRadius: 999,
      ),
      StudyCafeLayoutElementType.fixture => _ElementStyle(
        backgroundColor: AppColors.surfaceMuted,
        borderColor: selectedBorder,
        textColor: AppColors.textPrimary,
        borderRadius: 10,
      ),
    };
  }
}

class _EditableSeat extends StatelessWidget {
  final StudyCafeSeat seat;
  final bool isSelected;
  final double canvasWidth;
  final double canvasHeight;
  final double seatSize;
  final void Function(PartnerStudyCafeLayoutAction action) onAction;

  const _EditableSeat({
    required this.seat,
    required this.isSelected,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.seatSize,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = !seat.isEnabled
        ? AppColors.authProviderButton
        : (isSelected ? AppColors.primary : AppColors.white);
    final foregroundColor = isSelected
        ? AppColors.white
        : AppColors.textPrimary;
    final movableWidth = canvasWidth - seatSize;
    final movableHeight = canvasHeight - seatSize;
    final left = seat.x.clamp(0, 1).toDouble() * movableWidth;
    final top = seat.y.clamp(0, 1).toDouble() * movableHeight;

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () => onAction(
          PartnerStudyCafeLayoutAction.selectSeat(seat.seatId),
        ),
        onLongPress: () {
          onAction(PartnerStudyCafeLayoutAction.selectSeat(seat.seatId));
          _showSeatEditorSheet(context, seat, onAction);
        },
        onPanUpdate: (details) => onAction(
          PartnerStudyCafeLayoutAction.moveSeat(
            seatId: seat.seatId,
            deltaX: movableWidth == 0 ? 0 : details.delta.dx / movableWidth,
            deltaY: movableHeight == 0 ? 0 : details.delta.dy / movableHeight,
          ),
        ),
        child: Container(
          width: seatSize,
          height: seatSize,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              seat.label,
              style: TextStyle(
                color: foregroundColor,
                fontSize: (seatSize * 0.35).clamp(11.0, 15.0).toDouble(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _showElementEditorSheet(
  BuildContext context,
  StudyCafeLayoutElement element,
  void Function(PartnerStudyCafeLayoutAction action) onAction,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return _ElementEditorSheet(element: element, onAction: onAction);
    },
  );
}

void _showSeatEditorSheet(
  BuildContext context,
  StudyCafeSeat seat,
  void Function(PartnerStudyCafeLayoutAction action) onAction,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return _SeatEditorSheet(seat: seat, onAction: onAction);
    },
  );
}

class _ElementEditorSheet extends StatelessWidget {
  final StudyCafeLayoutElement element;
  final void Function(PartnerStudyCafeLayoutAction action) onAction;

  const _ElementEditorSheet({
    required this.element,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return _EditorSheetFrame(
      title: '${element.type.label} 설정',
      subtitle: '드래그로 위치를 옮기고, 여기서 크기와 표시 이름을 조정합니다.',
      child: Column(
        children: [
          TextFormField(
            key: ValueKey('element-label-${element.elementId}'),
            initialValue: element.label,
            decoration: const InputDecoration(labelText: '표시 이름'),
            onChanged: (value) => onAction(
              PartnerStudyCafeLayoutAction.changeSelectedElementLabel(value),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey(
                    'element-width-${element.elementId}-${element.width}',
                  ),
                  initialValue: (element.width * 100).round().toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '너비(%)'),
                  onChanged: (value) => onAction(
                    PartnerStudyCafeLayoutAction.changeSelectedElementWidth(
                      value,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: ValueKey(
                    'element-height-${element.elementId}-${element.height}',
                  ),
                  initialValue: (element.height * 100).round().toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '높이(%)'),
                  onChanged: (value) => onAction(
                    PartnerStudyCafeLayoutAction.changeSelectedElementHeight(
                      value,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey(
              'element-rotation-${element.elementId}-${element.rotation}',
            ),
            initialValue: element.rotation.round().toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '회전(도)'),
            onChanged: (value) => onAction(
              PartnerStudyCafeLayoutAction.changeSelectedElementRotation(value),
            ),
          ),
          const SizedBox(height: 16),
          _EditorDeleteButton(
            label: '구조물 삭제',
            onTap: () {
              onAction(
                const PartnerStudyCafeLayoutAction.removeSelectedElement(),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _SeatEditorSheet extends StatefulWidget {
  final StudyCafeSeat seat;
  final void Function(PartnerStudyCafeLayoutAction action) onAction;

  const _SeatEditorSheet({
    required this.seat,
    required this.onAction,
  });

  @override
  State<_SeatEditorSheet> createState() => _SeatEditorSheetState();
}

class _SeatEditorSheetState extends State<_SeatEditorSheet> {
  late bool isEnabled = widget.seat.isEnabled;

  @override
  Widget build(BuildContext context) {
    return _EditorSheetFrame(
      title: '좌석 설정',
      subtitle: '드래그로 위치를 옮기고, 여기서 좌석 이름과 사용 여부를 조정합니다.',
      child: Column(
        children: [
          TextFormField(
            key: ValueKey(widget.seat.seatId),
            initialValue: widget.seat.label,
            decoration: const InputDecoration(labelText: '좌석명'),
            onChanged: (value) => widget.onAction(
              PartnerStudyCafeLayoutAction.changeSelectedSeatLabel(value),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: isEnabled,
            title: const Text('이 좌석 사용'),
            subtitle: const Text('비활성화하면 고객이 선택할 수 없습니다.'),
            activeThumbColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                isEnabled = value;
              });
              widget.onAction(
                PartnerStudyCafeLayoutAction.toggleSelectedSeatEnabled(value),
              );
            },
          ),
          const SizedBox(height: 16),
          _EditorDeleteButton(
            label: '좌석 삭제',
            onTap: () {
              widget.onAction(
                const PartnerStudyCafeLayoutAction.removeSelectedSeat(),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _EditorSheetFrame extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _EditorSheetFrame({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(subtitle, style: AppTextStyles.bodySecondary),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorDeleteButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _EditorDeleteButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.delete_outline_rounded),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.danger,
        side: BorderSide(color: AppColors.danger.withValues(alpha: 0.35)),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _UsageOptionEditor extends StatelessWidget {
  final PartnerStudyCafeLayoutState state;
  final void Function(PartnerStudyCafeLayoutAction action) onAction;

  const _UsageOptionEditor({
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '이용권 설정',
      trailing: TextButton.icon(
        onPressed: () => onAction(
          const PartnerStudyCafeLayoutAction.addUsageOption(),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('추가'),
      ),
      child: Column(
        children: [
          if (state.usageOptions.isEmpty)
            Text('등록된 이용권이 없습니다.', style: AppTextStyles.bodySecondary),
          for (var i = 0; i < state.usageOptions.length; i++) ...[
            _UsageOptionTile(
              index: i,
              durationMinutes: state.usageOptions[i].durationMinutes,
              price: state.usageOptions[i].price,
              isEnabled: state.usageOptions[i].isEnabled,
              onAction: onAction,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _UsageOptionTile extends StatelessWidget {
  final int index;
  final int durationMinutes;
  final int price;
  final bool isEnabled;
  final void Function(PartnerStudyCafeLayoutAction action) onAction;

  const _UsageOptionTile({
    required this.index,
    required this.durationMinutes,
    required this.price,
    required this.isEnabled,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('duration-$index-$durationMinutes'),
                    initialValue: durationMinutes.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '이용 시간(분)'),
                    onChanged: (value) => onAction(
                      PartnerStudyCafeLayoutAction.changeUsageOptionDuration(
                        index: index,
                        value: value,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('price-$index-$price'),
                    initialValue: price.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '가격(원)'),
                    onChanged: (value) => onAction(
                      PartnerStudyCafeLayoutAction.changeUsageOptionPrice(
                        index: index,
                        value: value,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isEnabled,
                    title: const Text('활성화'),
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) => onAction(
                      PartnerStudyCafeLayoutAction.toggleUsageOptionEnabled(
                        index: index,
                        value: value,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onAction(
                    PartnerStudyCafeLayoutAction.removeUsageOption(index),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
