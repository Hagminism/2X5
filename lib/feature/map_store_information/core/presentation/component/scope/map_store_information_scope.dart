import 'package:capstone_2026/feature/map_store_information/presentation/screen/map_store_information_screen_root.dart';
import 'package:capstone_2026/feature/map_store_information/presentation/screen/map_store_information_view_model.dart';
import 'package:flutter/material.dart';

class MapStoreInformationScope extends StatefulWidget {
  final MapStoreInformationViewModel viewModel;
  final String storeId;

  const MapStoreInformationScope({
    super.key,
    required this.viewModel,
    required this.storeId,
  });

  @override
  State<MapStoreInformationScope> createState() =>
      _MapStoreInformationScopeState();
}

class _MapStoreInformationScopeState extends State<MapStoreInformationScope> {
  late final MapStoreInformationViewModel _viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return MapStoreInformationScreenRoot(
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
