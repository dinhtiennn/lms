import 'package:flutter/cupertino.dart';

export 'network_State.dart';
export 'verify_model.dart';
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
export 'document_model.dart';
export 'chat_box_model.dart';

// Lớp hỗ trợ cho nút hành động
class ActionButton {
  final String label;
  final IconData icon;
  final Color color;
  final Function onTap;
  final bool outlined;

  ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });
}
