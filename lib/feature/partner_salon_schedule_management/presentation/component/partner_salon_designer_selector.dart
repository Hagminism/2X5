import 'package:capstone_2026/core/domain/model/salon/salon_designer.dart';
import 'package:flutter/material.dart';

class PartnerSalonDesignerSelector extends StatelessWidget {
  final List<SalonDesigner> designers;
  final String? selectedDesignerId;
  final void Function(String designerId) onSelected;

  const PartnerSalonDesignerSelector({
    super.key,
    required this.designers,
    required this.selectedDesignerId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: designers
          .map(
            (designer) => ChoiceChip(
              label: Text(designer.name),
              selected: selectedDesignerId == designer.id,
              onSelected: (_) {
                onSelected(designer.id);
              },
            ),
          )
          .toList(),
    );
  }
}
