import 'package:get/get.dart';

import '../../auth/controller/auth_controller.dart';
import '../model/chat_message.dart';

class ChatController extends GetxController {
  ChatController(this._gateway, this._auth, this._now);

  final ChatGateway _gateway;
  final AuthController _auth;
  final DateTime Function() _now;
  final conversations = <String, List<ChatMessage>>{}.obs;
  late final Worker _session;

  @override
  void onInit() {
    super.onInit();
    _session = ever(_auth.account, (_) => _load());
  }

  void open(String doctorId) {
    final account = _auth.account.value;
    if (account == null) return;
    _gateway.startConversation(account.id, doctorId, _now());
    _load();
  }

  void send(String doctorId, String text) {
    final account = _auth.account.value;
    final body = text.trim();
    if (account == null || body.isEmpty) return;
    _gateway.sendMessage(account.id, doctorId, body, _now());
    _load();
  }

  void _load() {
    final account = _auth.account.value;
    conversations.assignAll(
      account == null ? {} : _gateway.conversations(account.id),
    );
  }

  @override
  void onClose() {
    _session.dispose();
    super.onClose();
  }
}
