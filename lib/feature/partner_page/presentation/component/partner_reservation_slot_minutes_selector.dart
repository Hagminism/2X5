import 'package:flutter/material.dart';

class PartnerReservationSlotMinutesSelector extends StatelessWidget {
  final int selectedSlotMinutes;
  final void Function(int minutes) onChanged;

  const PartnerReservationSlotMinutesSelector({
    super.key,
    required this.selectedSlotMinutes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('30분'),
          selected: selectedSlotMinutes == 30,
          onSelected: (_) {
            onChanged(30);
          },
        ),
        ChoiceChip(
          label: const Text('60분'),
          selected: selectedSlotMinutes == 60,
          onSelected: (_) {
            onChanged(60);
          },
        ),
      ],
    );
  }
}
