import 'package:lms/src/utils/app_utils.dart';

class CommentModel {
  final String? chapterId;
  final String? courseId;
  final String? commentId;
  final String? username;
  final String? fullname;
  final String? avatar;
  final String? detail;
  final DateTime? createdDate;
  final DateTime? lastUpdate;
  final int? countOfReply;
  final List<ReplyModel>? commentReplyResponses;

  CommentModel({
    this.chapterId,
    this.courseId,
    this.commentId,
    this.username,
    this.fullname,
    this.avatar,
    this.detail,
    this.createdDate,
    this.countOfReply,
    this.lastUpdate,
    this.commentReplyResponses,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        chapterId: json["chapterId"],
        courseId: json["courseId"],
        commentId: json["commentId"],
        username: json["username"],
        fullname: json["fullname"],
        avatar: json["avatar"],
        detail: json["detail"],
        lastUpdate: json["updateDate"] == null
            ? null
            : AppUtils.fromUtcStringToVnTime(json["updateDate"]),
        countOfReply: json["countOfReply"],
        createdDate: json["createdDate"] == null
            ? null
            : AppUtils.fromUtcStringToVnTime(json["createdDate"]),
        commentReplyResponses: json["commentReplyResponses"] == null
            ? []
            : ReplyModel.listFromJson(json["commentReplyResponses"]),
      );

  Map<String, dynamic> toJson() => {
        "chapterId": chapterId,
        "courseId": courseId,
        "commentId": commentId,
        "username": username,
        "fullname": fullname,
        "avatar": avatar,
        "detail": detail,
        "countOfReply": countOfReply,
        "updateDate": lastUpdate,
        "createdDate": AppUtils.toOffsetDateTimeString(createdDate),
        "commentReplyResponses": commentReplyResponses == null
            ? []
            : List<dynamic>.from(commentReplyResponses!.map((x) => x)),
      };

  static List<CommentModel> listFromJson(List<dynamic> jsonList) {
    final list = jsonList.map((json) => CommentModel.fromJson(json)).toList();
    list.sort((a, b) => (b.createdDate ?? DateTime.now())
        .compareTo(a.createdDate ?? DateTime.now()));
    return list;
  }

  CommentModel copyWith({
    String? chapterId,
    String? courseId,
    String? commentId,
    String? username,
    String? fullname,
    String? avatar,
    String? detail,
    DateTime? createdDate,
    DateTime? lastUpdate,
    int? countOfReply,
    List<ReplyModel>? commentReplyResponses,
  }) {
    return CommentModel(
      chapterId: chapterId ?? this.chapterId,
      courseId: courseId ?? this.courseId,
      commentId: commentId ?? this.commentId,
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      avatar: avatar ?? this.avatar,
      detail: detail ?? this.detail,
      createdDate: createdDate ?? this.createdDate,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      countOfReply: countOfReply ?? this.countOfReply,
      commentReplyResponses:
          commentReplyResponses ?? this.commentReplyResponses,
    );
  }

  @override
  String toString() {
    return 'CommentModel{chapterId: $chapterId, courseId: $courseId, commentId: $commentId, username: $username, fullname: $fullname, avatar: $avatar, detail: $detail, createdDate: $createdDate, lastUpdate: $lastUpdate, commentReplyResponses: $commentReplyResponses}, countOfReply: $countOfReply}';
  }
}

class ReplyModel {
  final String? commentId;
  final String? commentReplyId;
  final String? usernameOwner;
  final String? fullnameOwner;
  final String? usernameReply;
  final String? fullnameReply;
  final String? avatarReply;
  final String? detail;
  final DateTime? createdDate;
  final DateTime? lastUpdate;
  final int? replyCount;

  ReplyModel({
    this.commentId,
    this.commentReplyId,
    this.usernameOwner,
    this.fullnameOwner,
    this.usernameReply,
    this.fullnameReply,
    this.avatarReply,
    this.detail,
    this.createdDate,
    this.lastUpdate,
    this.replyCount,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) => ReplyModel(
        commentId: json["commentId"],
        commentReplyId: json["commentReplyId"],
        usernameOwner: json["usernameOwner"],
        fullnameOwner: json["fullnameOwner"],
        usernameReply: json["usernameReply"],
        fullnameReply: json["fullnameReply"],
        avatarReply: json["avatarReply"],
        detail: json["detail"],
        replyCount: json["replyCount"],
        lastUpdate: json["updateDate"] == null
            ? null
            : AppUtils.fromUtcStringToVnTime(json["updateDate"]),
        createdDate: json["createdDate"] == null
            ? null
            : AppUtils.fromUtcStringToVnTime(json["createdDate"]),
      );

  Map<String, dynamic> toJson() => {
        "commentId": commentId,
        "commentReplyId": commentReplyId,
        "usernameOwner": usernameOwner,
        "fullnameOwner": fullnameOwner,
        "usernameReply": usernameReply,
        "fullnameReply": fullnameReply,
        "avatarReply": avatarReply,
        "detail": detail,
        "countOfReply": replyCount,
        "updateDate": AppUtils.toOffsetDateTimeString(lastUpdate),
        "createdDate": AppUtils.toOffsetDateTimeString(createdDate),
      };

  static List<ReplyModel> listFromJson(List<dynamic> jsonList) {
    final list = jsonList.map((json) => ReplyModel.fromJson(json)).toList();
    list.sort((a, b) => (a.createdDate ?? DateTime.now())
        .compareTo(b.createdDate ?? DateTime.now()));
    return list;
  }

  ReplyModel copyWith({
    String? commentId,
    String? commentReplyId,
    String? usernameOwner,
    String? fullnameOwner,
    String? usernameReply,
    String? fullnameReply,
    String? avatarReply,
    String? detail,
    DateTime? createdDate,
    DateTime? lastUpdate,
    int? replyCount,
  }) {
    return ReplyModel(
      commentId: commentId ?? this.commentId,
      commentReplyId: commentReplyId ?? this.commentReplyId,
      usernameOwner: usernameOwner ?? this.usernameOwner,
      fullnameOwner: fullnameOwner ?? this.fullnameOwner,
      usernameReply: usernameReply ?? this.usernameReply,
      fullnameReply: fullnameReply ?? this.fullnameReply,
      avatarReply: avatarReply ?? this.avatarReply,
      detail: detail ?? this.detail,
      createdDate: createdDate ?? this.createdDate,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      replyCount: replyCount ?? this.replyCount,
    );
  }

  @override
  String toString() {
    return 'ReplyModel{commentId: $commentId, commentReplyId: $commentReplyId, usernameOwner: $usernameOwner, fullnameOwner: $fullnameOwner, usernameReply: $usernameReply, fullnameReply: $fullnameReply, avatarReply: $avatarReply, detail: $detail, createdDate: $createdDate, lastUpdate: $lastUpdate, replyCount: $replyCount}';
  }
}
