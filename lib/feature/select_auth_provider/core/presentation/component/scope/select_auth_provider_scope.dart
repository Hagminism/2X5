import 'package:app_links/app_links.dart';
import 'package:capstone_2026/feature/select_auth_provider/presentation/screen/select_auth_provider_screen_root.dart';
import 'package:capstone_2026/feature/select_auth_provider/presentation/screen/select_auth_provider_view_model.dart';
import 'package:flutter/material.dart';

class SelectAuthProviderScope extends StatefulWidget {
  final SelectAuthProviderViewModel viewModel;
  final AppLinks appLinks;

  const SelectAuthProviderScope({
    super.key,
    required this.viewModel,
    required this.appLinks,
  });

  @override
  State<SelectAuthProviderScope> createState() =>
      _SelectAuthProviderScopeState();
}

class _SelectAuthProviderScopeState extends State<SelectAuthProviderScope> {
  late final SelectAuthProviderViewModel viewModel = widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return SelectAuthProviderScreenRoot(
      viewModel: viewModel,
      appLinks: widget.appLinks,
    );
  }
}
