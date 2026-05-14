import 'package:capstone_2026/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'information_screen.dart';
import 'information_view_model.dart';

class InformationScreenRoot extends StatefulWidget {
  final InformationViewModel viewModel;
  final String storeId;
  final String name;
  final String subtitle;
  final double rating;
  final String category;

  const InformationScreenRoot({
    super.key,
    required this.viewModel,
    required this.storeId,
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.category,
  });

  @override
  State<InformationScreenRoot> createState() => _InformationScreenRootState();
}

class _InformationScreenRootState extends State<InformationScreenRoot> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.subtitle.isNotEmpty ||
          widget.rating != 0.0 ||
          widget.category.isNotEmpty) {
        widget.viewModel.setInitialData(
          name: widget.name,
          subtitle: widget.subtitle,
          rating: widget.rating,
          category: widget.category,
        );
      }
      widget.viewModel.fetchStore(widget.storeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading && !widget.viewModel.hasStoreData) {
            return const Scaffold(
              backgroundColor: AppColors.surface,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          if (widget.viewModel.errorMessage != null &&
              !widget.viewModel.hasStoreData) {
            return Scaffold(
              backgroundColor: AppColors.surface,
              appBar: AppBar(backgroundColor: AppColors.surface),
              body: Center(child: Text(widget.viewModel.errorMessage!)),
            );
          }

          return InformationScreen(
            storeId: widget.storeId,
            name: widget.viewModel.name.isEmpty ? widget.name : widget.viewModel.name,
            subtitle: widget.viewModel.subtitle.isEmpty ? widget.subtitle : widget.viewModel.subtitle,
            rating: widget.viewModel.rating == 0.0 ? widget.rating : widget.viewModel.rating,
            naverPlaceId: widget.viewModel.naverPlaceId,
          );
        },
      ),
    );
  }
}
