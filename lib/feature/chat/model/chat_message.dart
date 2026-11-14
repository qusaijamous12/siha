class ChatMessage {
  const ChatMessage(
    this.text, {
    required this.sentAt,
    this.fromPatient = false,
  });

  final String text;
  final DateTime sentAt;
  final bool fromPatient;
}

abstract interface class ChatGateway {
  Map<String, List<ChatMessage>> conversations(String accountId);
  void startConversation(String accountId, String doctorId, DateTime now);
  void sendMessage(
    String accountId,
    String doctorId,
    String text,
    DateTime now,
  );
}
