import 'package:capstone_2026/feature/map_store_information/studycafe_seat_selection/presentation/screen/map_studycafe_seat_selection_screen_root.dart';
import 'package:capstone_2026/feature/map_store_information/studycafe_seat_selection/presentation/screen/map_studycafe_seat_selection_view_model.dart';
import 'package:flutter/material.dart';

class MapStudycafeSeatSelectionScope extends StatefulWidget {
  final MapStudycafeSeatSelectionViewModel viewModel;
  final String storeId;

  const MapStudycafeSeatSelectionScope({
    super.key,
    required this.viewModel,
    required this.storeId,
  });

  @override
  State<MapStudycafeSeatSelectionScope> createState() =>
      _MapStudycafeSeatSelectionScopeState();
}

class _MapStudycafeSeatSelectionScopeState
    extends State<MapStudycafeSeatSelectionScope> {
  late final MapStudycafeSeatSelectionViewModel _viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return MapStudycafeSeatSelectionScreenRoot(
      viewModel: _viewModel,
      storeId: widget.storeId,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
