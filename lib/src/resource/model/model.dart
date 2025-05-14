import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms/src/utils/app_utils.dart';

export 'network_State.dart';
export 'verify_model.dart';
export 'gemini_model.dart';
export 'course_model.dart';
export 'major_model.dart';
export 'student_model.dart';
export 'teacher_model.dart';
export 'chapter_model.dart';
export 'lesson_model.dart';
export 'progress_model.dart';
export 'comment_model.dart';
export 'request_to_course.dart';
export 'group_model.dart';
export 'notification_model.dart';

class MessageModel {
  final String? id;
  final String senderType;
  final String content;
  final DateTime sentAt;
  final int timestamp;
  final bool isRead;

  MessageModel({
    this.id,
    required this.senderType,
    required this.content,
    required this.sentAt,
    required this.timestamp,
    required this.isRead,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderType: json['senderType'],
      content: json['content'] ?? '',
      sentAt: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timestamp: (json['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'senderType': senderType,
      'sentAt': AppUtils.toOffsetDateTimeString(sentAt),
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderType,
    String? content,
    DateTime? sentAt,
    int? timestamp,
    bool? isRead,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderType: senderType ?? this.senderType,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
