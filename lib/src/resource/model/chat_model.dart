class ChatInfoModel {
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isOnline;
  final bool hasUnreadMessage;
  final int unreadCount;

  ChatInfoModel({
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isOnline,
    this.hasUnreadMessage = false,
    this.unreadCount = 0,
  });
}