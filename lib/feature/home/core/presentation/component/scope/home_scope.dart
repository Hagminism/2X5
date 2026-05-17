import 'package:capstone_2026/feature/home/presentation/screen/home_screen_root.dart';
import 'package:capstone_2026/feature/home/presentation/screen/home_view_model.dart';
import 'package:flutter/material.dart';

class HomeScope extends StatefulWidget {
  final HomeViewModel viewModel;

  const HomeScope({
    required this.viewModel,
    super.key,
  });

  @override
  State<HomeScope> createState() => _HomeScopeState();
}

class _HomeScopeState extends State<HomeScope> {
  late final HomeViewModel _viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return HomeScreenRoot(viewModel: _viewModel);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
