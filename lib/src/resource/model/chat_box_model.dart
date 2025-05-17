class ChatBoxModel {
  final String? id;
  final DateTime? createdAt;
  final String? createdBy;
  final String? name;
  final List<String>? memberAccountUsernames;
  final DateTime? updatedAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageBy;
  final bool? group;

  ChatBoxModel({
    this.id,
    this.createdAt,
    this.createdBy,
    this.name,
    this.memberAccountUsernames,
    this.updatedAt,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageBy,
    this.group,
  });

  factory ChatBoxModel.fromJson(Map<String, dynamic> json) => ChatBoxModel(
    id: json["id"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    createdBy: json["createdBy"],
    name: json["name"],
    memberAccountUsernames: json["memberAccountUsernames"] == null ? [] : List<String>.from(json["memberAccountUsernames"]!.map((x) => x)),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    lastMessage: json["lastMessage"],
    lastMessageAt: json["lastMessageAt"] == null ? null : DateTime.parse(json["lastMessageAt"]),
    lastMessageBy: json["lastMessageBy"],
    group: json["group"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "createdAt": createdAt?.toIso8601String(),
    "createdBy": createdBy,
    "name": name,
    "memberAccountUsernames": memberAccountUsernames == null ? [] : List<dynamic>.from(memberAccountUsernames!.map((x) => x)),
    "updatedAt": updatedAt?.toIso8601String(),
    "lastMessage": lastMessage,
    "lastMessageAt": lastMessageAt?.toIso8601String(),
    "lastMessageBy": lastMessageBy,
    "group": group,
  };

  static List<ChatBoxModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => ChatBoxModel.fromJson(json)).toList();
  }
}

class MessageModel {
  final String? id;
  final String? chatBoxId;
  final String? senderAccount;
  final String? content;
  final DateTime? createdAt;
  final dynamic path;
  final dynamic type;
  final dynamic filename;

  MessageModel({
    this.id,
    this.chatBoxId,
    this.senderAccount,
    this.content,
    this.createdAt,
    this.path,
    this.type,
    this.filename,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: json["id"],
    chatBoxId: json["chatBoxId"],
    senderAccount: json["senderAccount"],
    content: json["content"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    path: json["path"],
    type: json["type"],
    filename: json["filename"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "chatBoxId": chatBoxId,
    "senderAccount": senderAccount,
    "content": content,
    "createdAt": createdAt?.toIso8601String(),
    "path": path,
    "type": type,
    "filename": filename,
  };

  static List<MessageModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => MessageModel.fromJson(json)).toList();
  }
}