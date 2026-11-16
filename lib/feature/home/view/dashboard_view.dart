import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/care_widgets.dart';
import '../../auth/model/account.dart';
import '../../doctors/controller/doctors_controller.dart';
import '../../doctors/view/appointments_view.dart';
import '../../doctors/view/doctor_widgets.dart';
import '../../health/controller/health_controller.dart';
import '../../health/model/health_record.dart';
import '../../health/view/record_form.dart';
import '../../health/view/reminder_view.dart';
import '../controller/home_controller.dart';
import '../model/home_tab.dart';

class DashboardView extends StatelessWidget {
  const DashboardView(this.account, {super.key});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    final health = Get.find<HealthController>();
    final care = Get.find<DoctorsController>();
    return Obx(() {
      final tasks = health.tasks.toList();
      final completed = tasks
          .where((task) => task.status == ReminderStatus.done)
          .length;
      final nextVisit = care.upcoming.firstOrNull;
      final name = account.isDemo
          ? 'demo_name'.tr
          : account.name.split(RegExp(r'\s+')).first;
      return CareList(
        children: [
          Text(
            MaterialLocalizations.of(context).formatFullDate(DateTime.now()),
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'greeting'.trParams({'name': name}),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _PlanCard(total: tasks.length, completed: completed),
          const SizedBox(height: 22),
          SectionTitle('quick_actions'.tr),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns =
                  width >= 275 &&
                      MediaQuery.textScalerOf(context).scale(14) <= 21
                  ? 2
                  : 1;
              final itemWidth = (width - 10 * (columns - 1)) / columns;
              return Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: _QuickAction(
                      'add_medicine'.tr,
                      Icons.medication_outlined,
                      AppColors.mint,
                      AppColors.green,
                      () => showMedicineForm(context),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _QuickAction(
                      'find_doctor'.tr,
                      Icons.medical_services_outlined,
                      AppColors.amber,
                      AppColors.rust,
                      () => home.select(HomeTab.doctors),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          SectionTitle(
            'daily_schedule'.tr,
            action: tasks.isEmpty ? null : 'all'.tr,
            onTap: () => openPage(context, const ReminderView()),
          ),
          const SizedBox(height: 8),
          if (tasks.isEmpty)
            EmptyCard(Icons.schedule_rounded, 'empty_reminders'.tr),
          for (final task in tasks.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ReminderTile(task: task),
            ),
          if (nextVisit != null) ...[
            const SizedBox(height: 17),
            SectionTitle('next_visit'.tr),
            const SizedBox(height: 8),
            AppointmentTile(
              nextVisit,
              onTap: () => openPage(context, const AppointmentsView()),
            ),
          ],
        ],
      );
    });
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.total, required this.completed});

  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.forest, Color(0xFF236953)],
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
      ),
      borderRadius: BorderRadius.circular(25),
    ),
    padding: const EdgeInsetsDirectional.fromSTEB(20, 17, 8, 17),
    child: LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.favorite_outline_rounded,
                  color: AppColors.lime,
                  size: 21,
                ),
                const SizedBox(height: 8),
                Text(
                  'daily_plan'.tr,
                  style: const TextStyle(
                    color: AppColors.surface,
                    fontSize: 21,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  total == 0
                      ? 'plan_empty'.tr
                      : 'progress'.trParams({
                          'done': MaterialLocalizations.of(context)
                              .formatDecimal(completed),
                          'total': MaterialLocalizations.of(context)
                              .formatDecimal(total),
                        }),
                  style: const TextStyle(
                    color: Color(0xFFD7EBDF),
                    fontSize: 13,
                  ),
                ),
                if (total > 0) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: completed / total,
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(5),
                    color: AppColors.lime,
                    backgroundColor: const Color(0xFF53836F),
                  ),
                ],
              ],
            ),
          ),
          if (constraints.maxWidth >= 230)
            Image.asset(
              'assets/images/care-heart.png',
              width: (constraints.maxWidth * .36).clamp(80, 160),
              excludeFromSemantics: true,
            ),
        ],
      ),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(
    this.label,
    this.icon,
    this.background,
    this.foreground,
    this.onTap,
  );

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CareCard(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    onTap: onTap,
    child: SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          CareIcon(icon, background: background, color: foreground, size: 38),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}
