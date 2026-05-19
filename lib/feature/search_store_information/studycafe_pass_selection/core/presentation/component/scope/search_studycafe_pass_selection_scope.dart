import 'package:capstone_2026/feature/search_store_information/studycafe_pass_selection/presentation/screen/search_studycafe_pass_selection_screen_root.dart';
import 'package:capstone_2026/feature/search_store_information/studycafe_pass_selection/presentation/screen/search_studycafe_pass_selection_view_model.dart';
import 'package:flutter/material.dart';

class SearchStudycafePassSelectionScope extends StatefulWidget {
  final SearchStudycafePassSelectionViewModel viewModel;
  final Map<String, String> seatInfo;

  const SearchStudycafePassSelectionScope({
    super.key,
    required this.viewModel,
    required this.seatInfo,
  });

  @override
  State<SearchStudycafePassSelectionScope> createState() =>
      _SearchStudycafePassSelectionScopeState();
}

class _SearchStudycafePassSelectionScopeState
    extends State<SearchStudycafePassSelectionScope> {
  late final SearchStudycafePassSelectionViewModel _viewModel =
      widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return SearchStudycafePassSelectionScreenRoot(
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
