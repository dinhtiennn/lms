import 'package:lms/src/resource/model/account_model.dart';
import 'package:lms/src/utils/utils.dart';

class ChatBoxModel {
  final String? id;
  final DateTime? createdAt;
  final String? createdBy;
  final String? name;
  final List<AccountModel>? memberAccountUsernames;
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
        createdAt: json["createdAt"] == null ? null : AppUtils.fromUtcStringToVnTime(json["createdAt"]),
        createdBy: json["createdBy"],
        name: json["name"],
        memberAccountUsernames:
            json["memberAccountUsernames"] == null ? [] : AccountModel.listFromJson(json["memberAccountUsernames"]),
        updatedAt: json["updatedAt"] == null ? null : AppUtils.fromUtcStringToVnTime(json["updatedAt"]),
        lastMessage: json["lastMessage"],
        lastMessageAt: json["lastMessageAt"] == null ? null : AppUtils.fromUtcStringToVnTime(json["lastMessageAt"]),
        lastMessageBy: json["lastMessageBy"],
        group: json["group"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "createdAt": createdAt?.toIso8601String(),
        "createdBy": createdBy,
        "name": name,
        "memberAccountUsernames":
            memberAccountUsernames == null ? [] : List<AccountModel>.from(memberAccountUsernames!.map((x) => x)),
        "updatedAt": updatedAt?.toIso8601String(),
        "lastMessage": lastMessage,
        "lastMessageAt": lastMessageAt?.toIso8601String(),
        "lastMessageBy": lastMessageBy,
        "group": group,
      };

  static List<ChatBoxModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => ChatBoxModel.fromJson(json)).toList();
  }

  ChatBoxModel copyWith({
    String? id,
    DateTime? createdAt,
    String? createdBy,
    String? name,
    List<AccountModel>? memberAccountUsernames,
    DateTime? updatedAt,
    String? lastMessage,
    DateTime? lastMessageAt,
    String? lastMessageBy,
    bool? group,
  }) {
    return ChatBoxModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      name: name ?? this.name,
      memberAccountUsernames: memberAccountUsernames ?? this.memberAccountUsernames,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageBy: lastMessageBy ?? this.lastMessageBy,
      group: group ?? this.group,
    );
  }
}

class MessageModel {
  final String? id;
  final String? chatBoxId;
  final String? senderAccount;
  final String? avatarSenderAccount;
  final String? content;
  final DateTime? createdAt;
  final dynamic path;
  final dynamic type;
  final dynamic filename;
  final String? status;

  MessageModel({
    this.id,
    this.chatBoxId,
    this.senderAccount,
    this.avatarSenderAccount,
    this.content,
    this.createdAt,
    this.path,
    this.type,
    this.filename,
    this.status,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json["id"],
        chatBoxId: json["chatBoxId"],
        senderAccount: json["senderAccount"],
        avatarSenderAccount: json["avatarSenderAccount"],
        content: json["content"],
        createdAt: json["createdAt"] == null ? null : AppUtils.fromUtcStringToVnTime(json["createdAt"]),
        path: json["path"],
        type: json["type"],
        filename: json["filename"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "chatBoxId": chatBoxId,
        "senderAccount": senderAccount,
        "avatarSenderAccount": avatarSenderAccount,
        "content": content,
        "createdAt": createdAt?.toIso8601String(),
        "path": path,
        "type": type,
        "filename": filename,
        "status": status,
      };

  static List<MessageModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => MessageModel.fromJson(json)).toList();
  }
}

class ChatBoxCreateRequest {
  final List<String> anotherAccounts;
  final String? groupName;
  final String currentAccountUsername;

  ChatBoxCreateRequest({
    required this.anotherAccounts,
    this.groupName,
    required this.currentAccountUsername,
  });

  Map<String, dynamic> toJson() => {
        "anotherAccounts": anotherAccounts,
        "groupName": groupName,
        "currentAccountUsername": currentAccountUsername,
      };
}

class ChatBoxMemberResponse {
  final String memberAccountUsername;

  ChatBoxMemberResponse({
    required this.memberAccountUsername,
  });

  factory ChatBoxMemberResponse.fromJson(Map<String, dynamic> json) => ChatBoxMemberResponse(
        memberAccountUsername: json["memberAccountUsername"],
      );
}

class ChatBoxCreateResponse {
  final String? chatBoxId;
  final List<ChatBoxMemberResponse> listMemmber;
  final String? groupName;

  ChatBoxCreateResponse({
    this.chatBoxId,
    required this.listMemmber,
    this.groupName,
  });

  factory ChatBoxCreateResponse.fromJson(Map<String, dynamic> json) => ChatBoxCreateResponse(
        chatBoxId: json["chatBoxId"],
        listMemmber: json["listMemmber"] == null
            ? []
            : List<ChatBoxMemberResponse>.from(json["listMemmber"].map((x) => ChatBoxMemberResponse.fromJson(x))),
        groupName: json["groupName"],
      );
}
