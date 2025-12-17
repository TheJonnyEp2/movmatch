class ChatModel {
  final String name;
  final String lastMessage;
  final String time;
  final bool isNew;
  final String avatar;

  ChatModel({
    required this.name,
    required this.lastMessage,
    required this.time,
    this.isNew = false,
    required this.avatar,
  });
}
