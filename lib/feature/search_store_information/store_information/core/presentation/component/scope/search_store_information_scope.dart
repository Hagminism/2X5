import 'package:capstone_2026/feature/search_store_information/store_information/presentation/screen/search_store_information_screen_root.dart';
import 'package:capstone_2026/feature/search_store_information/store_information/presentation/screen/search_store_information_view_model.dart';
import 'package:flutter/material.dart';

class SearchStoreInformationScope extends StatefulWidget {
  final SearchStoreInformationViewModel viewModel;
  final String storeId;

  const SearchStoreInformationScope({
    super.key,
    required this.viewModel,
    required this.storeId,
  });

  @override
  State<SearchStoreInformationScope> createState() =>
      _SearchStoreInformationScopeState();
}

class _SearchStoreInformationScopeState
    extends State<SearchStoreInformationScope> {
  late final SearchStoreInformationViewModel _viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return SearchStoreInformationScreenRoot(
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
