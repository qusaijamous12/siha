import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/care_widgets.dart';
import '../controller/doctors_controller.dart';
import '../model/doctor.dart';
import 'appointments_view.dart';
import 'doctor_detail_view.dart';
import 'doctor_widgets.dart';

class DoctorsView extends StatelessWidget {
  const DoctorsView({super.key});

  @override
  Widget build(BuildContext context) {
    final care = Get.find<DoctorsController>();
    return Obx(() {
      final doctors = care.filteredDoctors;
      final specialty = care.filter.value;
      return CareList(
        children: [
          PageIntro('find_doctor'.tr, 'doctor_intro'.tr),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: care.query.value,
            onChanged: (text) => care.query.value = text,
            decoration: InputDecoration(
              hintText: 'search_doctors'.tr,
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 3,
            children: [
              for (final type in [null, ...Specialty.values])
                ChoiceChip(
                  label: Text((type?.name ?? 'all').tr),
                  selected: type == specialty,
                  onSelected: (_) => care.filter.value = type,
                ),
            ],
          ),
          const SizedBox(height: 12),
          SectionTitle(
            'doctors'.tr,
            action: 'appointments'.tr,
            onTap: () => openPage(context, const AppointmentsView()),
          ),
          const SizedBox(height: 8),
          if (doctors.isEmpty)
            EmptyCard(Icons.search_off_rounded, 'no_doctors'.tr),
          for (final doctor in doctors)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DoctorTile(doctor),
            ),
        ],
      );
    });
  }
}

class _DoctorTile extends StatelessWidget {
  const _DoctorTile(this.doctor);

  final Doctor doctor;

  @override
  Widget build(BuildContext context) => CareCard(
    onTap: () => openPage(context, DoctorDetailView(doctor)),
    child: Row(
      children: [
        DoctorAvatar(doctor),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctor.id.tr,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 3),
              Text(
                doctor.specialty.name.tr,
                style: const TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                doctor.clinicKey.tr,
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        const Icon(
          Icons.arrow_forward_rounded,
          color: AppColors.green,
          size: 20,
        ),
      ],
    ),
  );
}
