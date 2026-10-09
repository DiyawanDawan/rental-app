class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    this.priority,
    this.actionLink,
    this.actionLabel,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String title;
  final String body;
  final String? type;
  final String? priority;
  final String? actionLink;
  final String? actionLabel;
  final Map<String, dynamic>? data;
  final bool isRead;
  final String createdAt;
  final String? readAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['message']?.toString() ?? json['body']?.toString() ?? '',
      type: json['type']?.toString(),
      priority: json['priority']?.toString(),
      actionLink: json['actionLink']?.toString(),
      actionLabel: json['actionLabel']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
      isRead: json['isRead'] == true || json['readAt'] != null,
      createdAt: json['createdAt']?.toString() ?? '',
      readAt: json['readAt']?.toString(),
    );
  }
}
