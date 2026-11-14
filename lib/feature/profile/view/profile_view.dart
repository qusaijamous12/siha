import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/care_widgets.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/model/account.dart';
import '../../doctors/view/appointments_view.dart';
import '../controller/profile_controller.dart';
import '../model/app_language.dart';

class ProfileView extends StatelessWidget {
  const ProfileView(this.account, {super.key});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    return CareList(
      children: [
        Text('profile'.tr, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        CareCard(
          child: Row(
            children: [
              const CareIcon(Icons.person_outline_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.isDemo ? 'demo_name'.tr : account.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      account.isDemo ? 'demo_account'.tr : account.email,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SectionTitle('language'.tr),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final item in AppLanguage.values)
              ChoiceChip(
                label: Text(item.name.tr),
                selected: item.code == language,
                onSelected: (_) =>
                    Get.find<ProfileController>().selectLanguage(item),
              ),
          ],
        ),
        const SizedBox(height: 16),
        CareCard(
          onTap: () => openPage(context, const AppointmentsView()),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: AppColors.green),
              const SizedBox(width: 10),
              Expanded(child: Text('appointments'.tr)),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: AppColors.green,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('demo_profile'.tr, style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 12),
        Obx(() {
          final auth = Get.find<AuthController>();
          final error = auth.error.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (error != null)
                Text(error.tr, style: const TextStyle(color: AppColors.red)),
              OutlinedButton.icon(
                onPressed: auth.busy.value ? null : auth.signOut,
                icon: const Icon(Icons.logout_rounded, size: 19),
                label: Text('sign_out'.tr),
              ),
            ],
          );
        }),
      ],
    );
  }
}
