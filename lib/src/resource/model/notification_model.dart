class NotificationView {
  final List<NotificationModel>? notifications;
  final Page? page;

  NotificationView({
    this.notifications,
    this.page,
  });

  factory NotificationView.fromJson(Map<String, dynamic> json) => NotificationView(
    notifications: json["content"] == null ? [] : List<NotificationModel>.from(json["content"]!.map((x) => NotificationModel.fromJson(x))),
    page: json["page"] == null ? null : Page.fromJson(json["page"]),
  );

  Map<String, dynamic> toJson() => {
    "content": notifications == null ? [] : List<dynamic>.from(notifications!.map((x) => x.toJson())),
    "page": page?.toJson(),
  };
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
    notificationType: notificationTypeValues.map[json["notificationType"]]!,
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

class Page {
  final int? size;
  final int? number;
  final int? totalElements;
  final int? totalPages;

  Page({
    this.size,
    this.number,
    this.totalElements,
    this.totalPages,
  });

  factory Page.fromJson(Map<String, dynamic> json) => Page(
    size: json["size"],
    number: json["number"],
    totalElements: json["totalElements"],
    totalPages: json["totalPages"],
  );

  Map<String, dynamic> toJson() => {
    "size": size,
    "number": number,
    "totalElements": totalElements,
    "totalPages": totalPages,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}