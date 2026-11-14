import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/care_widgets.dart';
import '../../doctors/model/doctor.dart';
import '../../doctors/view/doctor_widgets.dart';
import '../controller/chat_controller.dart';
import '../model/chat_message.dart';

class ConversationView extends StatefulWidget {
  const ConversationView(this.doctor, {super.key});

  final Doctor doctor;

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  final _draft = TextEditingController();

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = Get.find<ChatController>();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            DoctorAvatar(widget.doctor, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.doctor.id.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: StatusPill(
                    'demo_chat'.tr,
                    background: AppColors.lilac,
                    color: AppColors.purple,
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    final messages =
                        chat.conversations[widget.doctor.id] ??
                        const <ChatMessage>[];
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(18),
                      itemCount: messages.length,
                      itemBuilder: (context, index) =>
                          _MessageBubble(messages[messages.length - 1 - index]),
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 12, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _draft,
                          textInputAction: TextInputAction.send,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _send(chat),
                          decoration: InputDecoration(
                            hintText: 'message_hint'.tr,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ValueListenableBuilder(
                        valueListenable: _draft,
                        builder: (context, value, _) => IconButton.filled(
                          tooltip: 'send'.tr,
                          onPressed: value.text.trim().isEmpty
                              ? null
                              : () => _send(chat),
                          icon: const Icon(Icons.send_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _send(ChatController chat) {
    if (_draft.text.trim().isEmpty) return;
    chat.send(widget.doctor.id, _draft.text);
    _draft.clear();
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble(this.message);

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final patient = message.fromPatient;
    return Align(
      alignment: patient
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: .82,
        alignment: patient
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Align(
            alignment: patient
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: Container(
              decoration: BoxDecoration(
                color: patient ? AppColors.green : AppColors.surface,
                border: Border.all(
                  color: patient ? AppColors.green : AppColors.line,
                ),
                borderRadius: BorderRadius.circular(17),
              ),
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient ? message.text : message.text.tr,
                    style: TextStyle(
                      color: patient ? AppColors.surface : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    TimeOfDay.fromDateTime(message.sentAt).format(context),
                    style: TextStyle(
                      color: patient ? AppColors.mint : AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
