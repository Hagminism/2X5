import 'package:capstone_2026/feature/search_store_information/studycafe_seat_selection/presentation/screen/search_studycafe_seat_selection_screen_root.dart';
import 'package:capstone_2026/feature/search_store_information/studycafe_seat_selection/presentation/screen/search_studycafe_seat_selection_view_model.dart';
import 'package:flutter/material.dart';

class SearchStudycafeSeatSelectionScope extends StatefulWidget {
  final SearchStudycafeSeatSelectionViewModel viewModel;
  final String storeId;

  const SearchStudycafeSeatSelectionScope({
    super.key,
    required this.viewModel,
    required this.storeId,
  });

  @override
  State<SearchStudycafeSeatSelectionScope> createState() =>
      _SearchStudycafeSeatSelectionScopeState();
}

class _SearchStudycafeSeatSelectionScopeState
    extends State<SearchStudycafeSeatSelectionScope> {
  late final SearchStudycafeSeatSelectionViewModel _viewModel =
      widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return SearchStudycafeSeatSelectionScreenRoot(
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
