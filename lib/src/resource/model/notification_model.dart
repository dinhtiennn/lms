class NotificationView {
  final int? countUnreadNotification;
  final List<NotificationModel>? notifications;

  NotificationView({
    this.countUnreadNotification,
    this.notifications,
  });

  factory NotificationView.fromJson(Map<String, dynamic> json) =>
      NotificationView(
        notifications: json["notificationDetails"] == null ? [] : List<NotificationModel>.from(
            json["notificationDetails"]!.map((x) => NotificationModel.fromJson(x))),
        countUnreadNotification: json["countUnreadNotification"],
      );

  Map<String, dynamic> toJson() =>
      {
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
  final String? courseId;
  final String? lessonId;
  final String? chapterId;
  final String? postId;
  final String? chatBoxId;
  final NotificationType? notificationType;
  final bool? isRead;
  final String? description;
  final DateTime? createdAt;

  NotificationModel({
    this.notificationId,
    this.receivedAccountId,
    this.courseId,
    this.lessonId,
    this.chapterId,
    this.postId,
    this.chatBoxId,
    this.notificationType,
    this.isRead,
    this.description,
    this.createdAt,
  });

  NotificationModel copyWith({
    String? notificationId,
    String? receivedAccountId,
    String? courseId,
    String? lessonId,
    String? chapterId,
    String? postId,
    String? chatBoxId,
    NotificationType? notificationType,
    bool? isRead,
    String? description,
    DateTime? createdAt,
  }) =>
      NotificationModel(
        notificationId: notificationId ?? this.notificationId,
        receivedAccountId: receivedAccountId ?? this.receivedAccountId,
        courseId: courseId ?? this.courseId,
        lessonId: lessonId ?? this.lessonId,
        chapterId: chapterId ?? this.chapterId,
        postId: postId ?? this.postId,
        chatBoxId: chatBoxId ?? this.chatBoxId,
        notificationType: notificationType ?? this.notificationType,
        isRead: isRead ?? this.isRead,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
      );

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    notificationId: json["notificationId"],
    receivedAccountId: json["receivedAccountId"],
    courseId: json["courseId"],
    lessonId: json["lessonId"],
    chapterId: json["chapterId"],
    postId: json["postId"],
    chatBoxId: json["chatBoxId"],
    notificationType: notificationTypeValues.map[json["notificationType"]],
    isRead: json["isRead"],
    description: json["description"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "notificationId": notificationId,
    "receivedAccountId": receivedAccountId,
    "courseId": courseId,
    "lessonId": lessonId,
    "chapterId": chapterId,
    "postId": postId,
    "chatBoxId": chatBoxId,
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
  CHAT_MESSAGE,
  JOIN_CLASS_PENDING,
  JOIN_CLASS_REJECTED,
  JOIN_CLASS_APPROVED,
  POST_CREATED,
  POST_COMMENT,
  POST_COMMENT_REPLY
}

final notificationTypeValues = EnumValues({
  "MESSAGE": NotificationType.MESSAGE,
  "CHAT_MESSAGE": NotificationType.CHAT_MESSAGE,
  "COMMENT_REPLY": NotificationType.COMMENT_REPLY,
  "COMMENT": NotificationType.COMMENT,
  'JOIN_CLASS_PENDING': NotificationType.JOIN_CLASS_PENDING,
  'JOIN_CLASS_REJECTED': NotificationType.JOIN_CLASS_REJECTED,
  'JOIN_CLASS_APPROVED': NotificationType.JOIN_CLASS_APPROVED,
  'POST_CREATED': NotificationType.POST_CREATED,
  'POST_COMMENT': NotificationType.POST_COMMENT,
  'POST_COMMENT_REPLY': NotificationType.POST_COMMENT_REPLY,
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