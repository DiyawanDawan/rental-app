class ChatRoomModel {
  const ChatRoomModel({
    required this.id,
    this.name,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.otherUserAvatar,
    this.customerId,
    this.mitraUserId,
    this.bookingId,
  });

  final String id;
  final String? name;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;
  final String? otherUserAvatar;
  final String? customerId;
  final String? mitraUserId;
  final String? bookingId;

  factory ChatRoomModel.fromJson(Map<String, dynamic> json, [String? currentUserId]) {
    final otherUserMap = json['otherUser'] is Map<String, dynamic>
        ? json['otherUser'] as Map<String, dynamic>
        : null;

    // Resolve other user name & avatar from flat fields or nested objects
    String? resolvedName = json['name']?.toString() ?? otherUserMap?['fullName']?.toString();
    String? resolvedAvatar =
        json['otherUserAvatar']?.toString() ?? otherUserMap?['avatarUrl']?.toString();

    final cId = json['customerId']?.toString();
    final mId = json['mitraUserId']?.toString();

    if (resolvedName == null || resolvedName.isEmpty || resolvedName == 'Chat') {
      if (currentUserId != null && currentUserId.isNotEmpty) {
        if (currentUserId == cId) {
          resolvedName = json['mitraUserName']?.toString();
          resolvedAvatar ??= json['mitraUserAvatarUrl']?.toString();
        } else {
          resolvedName = json['customerName']?.toString();
          resolvedAvatar ??= json['customerAvatarUrl']?.toString();
        }
      } else {
        resolvedName = json['mitraUserName']?.toString() ?? json['customerName']?.toString();
        resolvedAvatar ??= json['mitraUserAvatarUrl']?.toString() ?? json['customerAvatarUrl']?.toString();
      }
    }

    // Resolve lastMessage whether it's a raw String or Map
    String? resolvedLastMessage;
    if (json['lastMessage'] is Map) {
      resolvedLastMessage = json['lastMessage']['content']?.toString();
    } else if (json['lastMessage'] != null) {
      resolvedLastMessage = json['lastMessage']?.toString();
    }

    // Resolve lastMessageTime
    final resolvedTime = json['lastMessageAt']?.toString() ??
        (json['lastMessage'] is Map ? json['lastMessage']['createdAt']?.toString() : null) ??
        json['createdAt']?.toString();

    // Resolve unreadCount
    final unread = (json['unreadCount'] as num?)?.toInt() ??
        (json['_count'] is Map ? (json['_count']['messages'] as num?)?.toInt() : null) ??
        0;

    return ChatRoomModel(
      id: json['id']?.toString() ?? '',
      name: resolvedName ?? 'Chat',
      lastMessage: resolvedLastMessage,
      lastMessageTime: resolvedTime,
      unreadCount: unread,
      otherUserAvatar: resolvedAvatar,
      customerId: cId,
      mitraUserId: mId,
      bookingId: json['bookingId']?.toString(),
    );
  }
}

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
    this.isMe = false,
    this.type = 'TEXT',
    this.mediaUrl,
    this.isRead = false,
    this.senderName,
    this.senderAvatarUrl,
  });

  final String id;
  final String content;
  final String senderId;
  final String createdAt;
  final bool isMe;
  final String type;
  final String? mediaUrl;
  final bool isRead;
  final String? senderName;
  final String? senderAvatarUrl;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    final sender = json['sender'] is Map<String, dynamic>
        ? json['sender'] as Map<String, dynamic>
        : null;

    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      isMe: json['senderId']?.toString() == currentUserId,
      type: json['type']?.toString().toUpperCase() ?? 'TEXT',
      mediaUrl: json['mediaUrl']?.toString(),
      isRead: json['isRead'] == true,
      senderName: json['senderName']?.toString() ?? sender?['fullName']?.toString(),
      senderAvatarUrl: json['senderAvatarUrl']?.toString() ?? sender?['avatarUrl']?.toString(),
    );
  }
}
