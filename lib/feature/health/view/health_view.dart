import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/care_widgets.dart';
import '../../check_in/controller/check_in_controller.dart';
import '../controller/health_controller.dart';
import '../model/health_record.dart';
import 'record_form.dart';

class HealthView extends StatelessWidget {
  const HealthView({super.key});

  @override
  Widget build(BuildContext context) {
    final health = Get.find<HealthController>();
    return Obx(() {
      final kind = health.selectedKind.value;
      final records = health.records
          .where((record) => record.kind == kind)
          .toList();
      final isMedicine = kind == RecordKind.medicine;
      final action = (isMedicine ? 'add_medicine' : 'add_condition').tr;
      return CareList(
        children: [
          PageIntro('health'.tr, 'health_intro'.tr),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: Get.find<CheckInController>().requestPrompt,
            icon: const Icon(Icons.monitor_heart_outlined),
            label: Text('check_in_title'.tr),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final type in RecordKind.values)
                ChoiceChip(
                  label: Text(
                    (type == RecordKind.medicine ? 'medicines' : 'conditions')
                        .tr,
                  ),
                  selected: type == kind,
                  onSelected: (_) => health.selectedKind.value = type,
                ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => showRecordForm(context, kind),
            icon: const Icon(Icons.add_rounded),
            label: Text(action),
          ),
          const SizedBox(height: 18),
          if (records.isEmpty)
            EmptyCard(
              isMedicine
                  ? Icons.medication_outlined
                  : Icons.monitor_heart_outlined,
              (isMedicine ? 'empty_medicines' : 'empty_conditions').tr,
            ),
          for (final record in records)
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
    final medicine = record.kind == RecordKind.medicine;
    final reminder = record.reminder;
    return CareCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CareIcon(
            medicine ? Icons.medication_outlined : Icons.monitor_heart_outlined,
            background: medicine ? AppColors.mint : AppColors.lilac,
            color: medicine ? AppColors.green : AppColors.purple,
          ),
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
      await showRecordForm(context, record.kind, record: record);
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
