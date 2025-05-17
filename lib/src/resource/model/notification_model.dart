class NotificationView {
  final int? countUnreadNotification;
  final List<NotificationModel>? notifications;

  NotificationView({
    this.countUnreadNotification,
    this.notifications,
  });

  factory NotificationView.fromJson(Map<String, dynamic> json) => NotificationView(
    notifications: json["notificationDetails"] == null ? [] : List<NotificationModel>.from(json["notificationDetails"]!.map((x) => NotificationModel.fromJson(x))),
    countUnreadNotification: json["countUnreadNotification"],
  );

  Map<String, dynamic> toJson() => {
    "content": notifications == null ? [] : List<dynamic>.from(notifications!.map((x) => x.toJson())),
    "countUnreadNotification": countUnreadNotification,
  };

  NotificationView copyWith({
    int? countUnreadNotification,
    List<NotificationModel>? notifications,
  }) {
    return NotificationView(
      countUnreadNotification: countUnreadNotification ?? this.countUnreadNotification,
      notifications: notifications ?? this.notifications,
    );
  }
}

class NotificationModel {
  final String? notificationId;
  final String? receivedAccountId;
  final String? commentId;
  final String? commentReplyId;
  final NotificationType? notificationType;
  final bool? isRead;
  final String? description;
  final DateTime? createdAt;

  NotificationModel({
    this.notificationId,
    this.receivedAccountId,
    this.commentId,
    this.commentReplyId,
    this.notificationType,
    this.isRead,
    this.description,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    notificationId: json["notificationId"],
    receivedAccountId: json["receivedAccountId"],
    commentId: json["commentId"],
    commentReplyId: json["commentReplyId"],
    notificationType: notificationTypeValues.map[json["notificationType"]] ?? NotificationType.MESSAGE,
    isRead: json["isRead"],
    description: json["description"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "notificationId": notificationId,
    "receivedAccountId": receivedAccountId,
    "commentId": commentId,
    "commentReplyId": commentReplyId,
    "notificationType": notificationTypeValues.reverse[notificationType],
    "isRead": isRead,
    "description": description,
    "createdAt": createdAt?.toIso8601String(),
  };
}

enum NotificationType {
  COMMENT,
  MESSAGE,
  COMMENT_REPLY,
  CHAT_MESSAGE
}

final notificationTypeValues = EnumValues({
  "COMMENT_REPLY": NotificationType.COMMENT_REPLY,
  "MESSAGE": NotificationType.MESSAGE,
  "COMMENT": NotificationType.COMMENT,
  "CHAT_MESSAGE": NotificationType.CHAT_MESSAGE
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}