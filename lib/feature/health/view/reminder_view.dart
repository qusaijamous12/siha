import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/care_widgets.dart';
import '../controller/health_controller.dart';
import '../model/health_record.dart';
import 'health_view.dart';

class ReminderView extends StatelessWidget {
  const ReminderView({super.key});

  @override
  Widget build(BuildContext context) {
    final health = Get.find<HealthController>();
    return Scaffold(
      appBar: AppBar(title: Text('reminders'.tr)),
      body: SafeArea(
        top: false,
        child: Obx(
          () => CareList(
            children: [
              Text(
                'daily_schedule'.tr,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              if (health.tasks.isEmpty)
                EmptyCard(
                  Icons.notifications_none_rounded,
                  'empty_reminders'.tr,
                ),
              for (final task in health.tasks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ReminderTile(task: task),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReminderTile extends StatelessWidget {
  const ReminderTile({super.key, required this.task});

  final ScheduledTask task;

  @override
  Widget build(BuildContext context) {
    final record = task.record;
    final isMedicine = record.kind == RecordKind.medicine;
    final done = task.status == ReminderStatus.done;
    final due = task.status == ReminderStatus.due;
    final time = TimeOfDay.fromDateTime(task.time).format(context);
    final title = isMedicine ? record.displayName : record.displayAction;
    final detail = isMedicine ? record.displayDetails : record.displayName;
    return CareCard(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 6, 10),
      child: Row(
        children: [
          CareIcon(
            isMedicine
                ? Icons.medication_outlined
                : Icons.monitor_heart_outlined,
            background: isMedicine ? AppColors.mint : AppColors.lilac,
            color: isMedicine ? AppColors.green : AppColors.purple,
            size: 42,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  detail.isEmpty ? time : '$time · $detail',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          if (due)
            StatusPill(
              'due'.tr,
              background: AppColors.amber,
              color: AppColors.rust,
            ),
          IconButton(
            tooltip: (done ? 'undo_done' : 'mark_done').tr,
            color: done ? AppColors.green : AppColors.muted,
            icon: Icon(
              done
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
            ),
            onPressed: () => Get.find<HealthController>().toggleTask(task),
          ),
        ],
      ),
    );
  }
}

class ReminderAlert extends StatelessWidget {
  const ReminderAlert({super.key});

  @override
  Widget build(BuildContext context) {
    final health = Get.find<HealthController>();
    return Obx(() {
      final task = health.foregroundAlert.value;
      if (task == null) return const SizedBox.shrink();
      final record = task.record;
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 6),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 660),
            child: Semantics(
              liveRegion: true,
              child: Material(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => openPage(context, const ReminderView()),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            12,
                            9,
                            2,
                            9,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.notifications_active_outlined,
                                color: AppColors.rust,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${'reminder'.tr} · ${record.kind == RecordKind.condition ? record.displayAction : record.displayName}',
                                  style: const TextStyle(
                                    color: AppColors.rust,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: MaterialLocalizations.of(context)
                          .closeButtonTooltip,
                      onPressed: () => health.dismissAlert(task),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.rust,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
