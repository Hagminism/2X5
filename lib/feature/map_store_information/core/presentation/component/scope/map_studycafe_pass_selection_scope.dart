import 'package:capstone_2026/feature/map_store_information/presentation/screen/map_studycafe_pass_selection_screen_root.dart';
import 'package:capstone_2026/feature/map_store_information/presentation/screen/map_studycafe_pass_selection_view_model.dart';
import 'package:flutter/material.dart';

class MapStudycafePassSelectionScope extends StatefulWidget {
  final MapStudycafePassSelectionViewModel viewModel;
  final Map<String, String> seatInfo;

  const MapStudycafePassSelectionScope({
    super.key,
    required this.viewModel,
    required this.seatInfo,
  });

  @override
  State<MapStudycafePassSelectionScope> createState() =>
      _MapStudycafePassSelectionScopeState();
}

class _MapStudycafePassSelectionScopeState
    extends State<MapStudycafePassSelectionScope> {
  late final MapStudycafePassSelectionViewModel _viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return MapStudycafePassSelectionScreenRoot(
      viewModel: _viewModel,
      seatInfo: widget.seatInfo,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
