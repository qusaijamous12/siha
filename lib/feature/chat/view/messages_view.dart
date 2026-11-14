import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/care_widgets.dart';
import '../../doctors/controller/doctors_controller.dart';
import '../../doctors/view/doctor_widgets.dart';
import '../controller/chat_controller.dart';
import 'conversation_view.dart';

class MessagesView extends StatelessWidget {
  const MessagesView({super.key, required this.onFindDoctor});

  final VoidCallback onFindDoctor;

  @override
  Widget build(BuildContext context) {
    final chat = Get.find<ChatController>();
    final doctors = Get.find<DoctorsController>().doctors;
    return Obx(() {
      final threads =
          doctors
              .where((doctor) => chat.conversations.containsKey(doctor.id))
              .toList()
            ..sort(
              (a, b) => chat.conversations[b.id]!.last.sentAt.compareTo(
                chat.conversations[a.id]!.last.sentAt,
              ),
            );
      return CareList(
        children: [
          PageIntro('messages'.tr, 'chat_intro'.tr),
          const SizedBox(height: 18),
          if (threads.isEmpty)
            EmptyCard(
              Icons.chat_bubble_outline_rounded,
              'empty_chat'.tr,
              action: 'find_doctor'.tr,
              onTap: onFindDoctor,
            ),
          for (final doctor in threads)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CareCard(
                onTap: () => openPage(context, ConversationView(doctor)),
                child: Row(
                  children: [
                    DoctorAvatar(doctor, size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.id.tr,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            chat.conversations[doctor.id]!.last.text.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.green,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}
