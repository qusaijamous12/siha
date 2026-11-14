import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/care_widgets.dart';
import '../../chat/controller/chat_controller.dart';
import '../../chat/view/conversation_view.dart';
import '../controller/doctors_controller.dart';
import '../model/doctor.dart';
import 'doctor_widgets.dart';

class DoctorDetailView extends StatelessWidget {
  const DoctorDetailView(this.doctor, {super.key});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('view_doctor'.tr)),
    body: SafeArea(
      top: false,
      child: CareList(
        children: [
          CareCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                DoctorAvatar(doctor, size: 76),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.id.tr,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        doctor.specialty.name.tr,
                        style: const TextStyle(color: AppColors.green),
                      ),
                      Text(
                        doctor.clinicKey.tr,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionTitle('about'.tr),
          const SizedBox(height: 7),
          Text(
            doctor.bioKey.tr,
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              constraints: const BoxConstraints(maxWidth: 580),
              builder: (context) => _BookingSheet(doctor),
            ),
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text('book'.tr),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Get.find<ChatController>().open(doctor.id);
              openPage(context, ConversationView(doctor));
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: Text('chat'.tr),
          ),
        ],
      ),
    ),
  );
}

class _BookingSheet extends StatefulWidget {
  const _BookingSheet(this.doctor);

  final Doctor doctor;

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  final care = Get.find<DoctorsController>();
  late DateTime date;
  DateTime? selected;

  @override
  void initState() {
    super.initState();
    date = care.bookingDays.first;
  }

  @override
  Widget build(BuildContext context) {
    final formats = MaterialLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        22,
        0,
        22,
        20 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Obx(() {
        final slots = care.availableTimes(widget.doctor, date);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('book'.tr, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              '${widget.doctor.id.tr} · ${'clinic_visit'.tr}',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            Text(
              'choose_date'.tr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final day in care.bookingDays)
                  ChoiceChip(
                    label: Text(formats.formatShortDate(day)),
                    selected: day == date,
                    onSelected: (_) => setState(() {
                      date = day;
                      selected = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'choose_time'.tr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            if (slots.isEmpty) Text('no_slots'.tr),
            Wrap(
              spacing: 8,
              children: [
                for (final time in slots)
                  ChoiceChip(
                    label: Text(TimeOfDay.fromDateTime(time).format(context)),
                    selected: time == selected,
                    onSelected: (_) => setState(() => selected = time),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: slots.contains(selected) ? _book : null,
              child: Text('confirm_booking'.tr),
            ),
          ],
        );
      }),
    );
  }

  void _book() {
    if (!care.book(widget.doctor, selected!)) {
      setState(() => selected = null);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text('booking_confirmed'.tr)));
  }
}
