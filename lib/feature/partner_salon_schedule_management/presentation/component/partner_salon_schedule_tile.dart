import 'package:capstone_2026/core/domain/model/salon/salon_designer_schedule.dart';
import 'package:capstone_2026/feature/partner_salon_schedule_management/presentation/screen/partner_salon_schedule_management_action.dart';
import 'package:capstone_2026/feature/partner_salon_service_management/presentation/component/partner_salon_management_tile.dart';
import 'package:flutter/material.dart';

class PartnerSalonScheduleTile extends StatelessWidget {
  final SalonDesignerSchedule schedule;
  final void Function(PartnerSalonScheduleManagementAction action) onAction;

  const PartnerSalonScheduleTile({
    super.key,
    required this.schedule,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return PartnerSalonManagementTile(
      title: _dayLabel(schedule.dayOfWeek),
      description: schedule.isWorking
          ? '${schedule.startTime} - ${schedule.endTime}'
          : '휴무',
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        onAction(
          PartnerSalonScheduleManagementAction.tapEditSchedule(schedule),
        );
      },
      onEdit: () {
        onAction(
          PartnerSalonScheduleManagementAction.tapEditSchedule(schedule),
        );
      },
    );
  }

  String _dayLabel(int dayOfWeek) {
    const labels = ['일', '월', '화', '수', '목', '금', '토'];
    if (dayOfWeek < 0 || dayOfWeek >= labels.length) {
      return '요일';
    }
    return '${labels[dayOfWeek]}요일';
  }
}
