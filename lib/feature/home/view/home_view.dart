import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/care_widgets.dart';
import '../../auth/model/account.dart';
import '../../chat/view/messages_view.dart';
import '../../doctors/view/doctors_view.dart';
import '../../health/controller/health_controller.dart';
import '../../health/model/health_record.dart';
import '../../health/view/health_view.dart';
import '../../health/view/reminder_view.dart';
import '../../profile/view/profile_view.dart';
import '../controller/home_controller.dart';
import '../model/home_tab.dart';
import 'dashboard_view.dart';

class HomeView extends StatelessWidget {
  const HomeView(this.account, {super.key});

  final Account account;

  static const _icons = {
    HomeTab.home: (Icons.home_outlined, Icons.home_rounded),
    HomeTab.health: (Icons.monitor_heart_outlined, Icons.monitor_heart_rounded),
    HomeTab.doctors: (
      Icons.medical_services_outlined,
      Icons.medical_services_rounded,
    ),
    HomeTab.messages: (
      Icons.chat_bubble_outline_rounded,
      Icons.chat_bubble_rounded,
    ),
    HomeTab.profile: (Icons.person_outline_rounded, Icons.person_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final labels = Get.translations[locale.languageCode] ?? const {};
    final home = Get.find<HomeController>();
    final health = Get.find<HealthController>();
    return Obx(() {
      final tab = home.selected.value;
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              const CareIcon(
                Icons.favorite_rounded,
                background: AppColors.forest,
                color: AppColors.lime,
                size: 34,
              ),
              const SizedBox(width: 8),
              Text('brand'.tr),
            ],
          ),
          actions: [
            Obx(
              () => IconButton(
                tooltip: 'reminders'.tr,
                onPressed: () => openPage(context, const ReminderView()),
                icon: Badge(
                  isLabelVisible: health.tasks.any(
                    (task) => task.status == ReminderStatus.due,
                  ),
                  backgroundColor: AppColors.rust,
                  child: const Icon(Icons.notifications_none_rounded),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              const ReminderAlert(),
              Expanded(
                child: KeyedSubtree(
                  key: ValueKey(tab),
                  child: switch (tab) {
                    HomeTab.home => DashboardView(account),
                    HomeTab.health => const HealthView(),
                    HomeTab.doctors => const DoctorsView(),
                    HomeTab.messages => MessagesView(
                      onFindDoctor: () => home.select(HomeTab.doctors),
                    ),
                    HomeTab.profile => ProfileView(account),
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: NavigationBar(
            selectedIndex: tab.index,
            onDestinationSelected: (index) =>
                home.select(HomeTab.values[index]),
            destinations: [
              for (final item in HomeTab.values)
                NavigationDestination(
                  icon: Icon(_icons[item]!.$1, size: 22),
                  selectedIcon: Icon(
                    _icons[item]!.$2,
                    size: 22,
                    color: AppColors.green,
                  ),
                  label: labels[item.name] ?? item.name.tr,
                ),
            ],
          ),
        ),
      );
    });
  }
}
