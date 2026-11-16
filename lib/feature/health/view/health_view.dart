import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/care_widgets.dart';
import '../../check_in/controller/check_in_controller.dart';
import '../../check_in/model/vital_reading.dart';
import '../../check_in/view/condition_trends_view.dart';
import '../controller/health_controller.dart';
import '../model/health_record.dart';
import 'record_form.dart';

class HealthView extends StatelessWidget {
  const HealthView({super.key});

  @override
  Widget build(BuildContext context) {
    final health = Get.find<HealthController>();
    final checkIn = Get.find<CheckInController>();
    return Obx(() {
      final medicines = health.records
          .where((record) => record.kind == RecordKind.medicine)
          .toList();
      final tracked = checkIn.history.value?.conditions ?? {};
      return CareList(
        children: [
          PageIntro('health'.tr, 'health_intro'.tr),
          const SizedBox(height: 16),
          SectionTitle('conditions'.tr),
          const SizedBox(height: 8),
          Text(
            tracked.isEmpty
                ? 'tracked_conditions_empty'.tr
                : TrackedCondition.values
                      .where(tracked.contains)
                      .map((condition) => ('check_in_${condition.name}').tr)
                      .join(' · '),
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: checkIn.requestPrompt,
            icon: const Icon(Icons.monitor_heart_outlined),
            label: Text('check_in_title'.tr),
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: () => openPage(context, const ConditionTrendsView()),
            icon: const Icon(Icons.show_chart_rounded),
            label: Text('trends_title'.tr),
          ),
          const SizedBox(height: 18),
          SectionTitle('medicines'.tr),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => showMedicineForm(context),
            icon: const Icon(Icons.add_rounded),
            label: Text('add_medicine'.tr),
          ),
          const SizedBox(height: 14),
          if (medicines.isEmpty)
            EmptyCard(Icons.medication_outlined, 'empty_medicines'.tr),
          for (final record in medicines)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RecordTile(record: record),
            ),
        ],
      );
    });
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final HealthRecord record;

  @override
  Widget build(BuildContext context) {
    final reminder = record.reminder;
    return CareCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CareIcon(Icons.medication_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (record.details.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.displayDetails,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
                if (reminder != null) ...[
                  const SizedBox(height: 8),
                  StatusPill(
                    TimeOfDay(
                      hour: reminder.minuteOfDay ~/ 60,
                      minute: reminder.minuteOfDay % 60,
                    ).format(context),
                  ),
                  if (reminder.action.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      record.displayAction,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _select(context, value),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text('edit'.tr)),
              PopupMenuItem(value: 'delete', child: Text('delete'.tr)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _select(BuildContext context, String value) async {
    if (value == 'edit') {
      await showMedicineForm(context, record: record);
    } else if (await confirmAction(
      context,
      title: 'delete_record'.tr,
      description: 'delete_record_body'.tr,
      action: 'delete'.tr,
    )) {
      Get.find<HealthController>().deleteRecord(record);
    }
  }
}

extension HealthRecordText on HealthRecord {
  String get displayName => isSample ? name.tr : name;
  String get displayDetails => isSample ? details.tr : details;
  String get displayAction {
    final action = reminder?.action ?? '';
    return isSample && action.isNotEmpty ? action.tr : action;
  }
}
