import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../core/widgets/care_widgets.dart';
import '../controller/doctors_controller.dart';
import '../model/doctor.dart';
import 'doctor_widgets.dart';

class AppointmentsView extends StatelessWidget {
  const AppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final care = Get.find<DoctorsController>();
    return Scaffold(
      appBar: AppBar(title: Text('appointments'.tr)),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final upcoming = care.upcoming;
          final past = care.visits
              .where((visit) => !upcoming.contains(visit))
              .toList()
              .reversed;
          return CareList(
            children: [
              SectionTitle('upcoming_appointments'.tr),
              const SizedBox(height: 10),
              if (upcoming.isEmpty)
                EmptyCard(
                  Icons.event_available_outlined,
                  'empty_appointments'.tr,
                ),
              for (final visit in upcoming)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppointmentTile(
                    visit,
                    onCancel: () => _cancel(context, care, visit),
                  ),
                ),
              if (past.isNotEmpty) ...[
                const SizedBox(height: 18),
                SectionTitle('past_appointments'.tr),
                const SizedBox(height: 10),
                for (final visit in past)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppointmentTile(visit),
                  ),
              ],
            ],
          );
        }),
      ),
    );
  }

  Future<void> _cancel(
    BuildContext context,
    DoctorsController care,
    Appointment visit,
  ) async {
    if (await confirmAction(
      context,
      title: 'cancel_visit_title'.tr,
      action: 'cancel_visit'.tr,
      cancel: 'keep_visit'.tr,
    )) {
      care.cancel(visit);
    }
  }
}
