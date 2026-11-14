import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/care_widgets.dart';
import '../model/doctor.dart';

class DoctorAvatar extends StatelessWidget {
  const DoctorAvatar(this.doctor, {super.key, this.size = 56});

  final Doctor doctor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (doctor.specialty) {
      Specialty.family => (AppColors.mint, AppColors.forest),
      Specialty.cardiology => (AppColors.lilac, AppColors.purple),
      Specialty.dermatology => (AppColors.amber, AppColors.rust),
    };
    final initials = Localizations.localeOf(context).languageCode == 'ar'
        ? doctor.arabicInitials
        : doctor.initials;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(size * .33),
        ),
        child: Text(
          initials,
          style: TextStyle(
            color: foreground,
            fontSize: size * .29,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class AppointmentTile extends StatelessWidget {
  const AppointmentTile(this.visit, {super.key, this.onTap, this.onCancel});

  final Appointment visit;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(context).formatMediumDate(visit.time);
    final time = TimeOfDay.fromDateTime(visit.time).format(context);
    return CareCard(
      onTap: onTap,
      child: Row(
        children: [
          DoctorAvatar(visit.doctor, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.doctor.id.tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  '$date · $time',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (onCancel != null)
            IconButton(
              onPressed: onCancel,
              tooltip: 'cancel_visit'.tr,
              icon: const Icon(Icons.event_busy_outlined, color: AppColors.red),
            )
          else if (onTap != null)
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.green,
              size: 22,
            ),
        ],
      ),
    );
  }
}
