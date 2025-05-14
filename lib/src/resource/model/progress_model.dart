import 'package:lms/src/utils/app_utils.dart';

class ProgressModel {
  final bool? isCompleted;
  final DateTime? completeAt;

  ProgressModel({
    this.isCompleted,
    this.completeAt,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) => ProgressModel(
    isCompleted: json["isCompleted"],
    completeAt: json["completeAt"] == null ? null : AppUtils.fromUtcStringToVnTime(json["completeAt"]),
  );

  Map<String, dynamic> toJson() => {
    "isCompleted": isCompleted,
    "completeAt": completeAt,
  };

  @override
  String toString() {
    return 'ProgressModel{isCompleted: $isCompleted, completeAt: $completeAt}';
  }
}