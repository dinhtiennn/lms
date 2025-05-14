import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/resource/model/teacher_model.dart';
import 'package:lms/src/utils/app_utils.dart';

class RequestModel {
  final String? id;
  final String? fullName;
  final MajorModel? major;
  final String? email;

  RequestModel({
    this.id,
    this.fullName,
    this.major,
    this.email,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) => RequestModel(
    id: json["id"],
    fullName: json["fullName"],
    major: json["major"] == null ? null : MajorModel.fromJson(json["major"]),
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "fullName": fullName,
    "major": major?.toJson(),
    "email": email,
  };

  static List<RequestModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => RequestModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

class RequestToCourseModel {
  final String? id;
  final String? name;
  final dynamic image;
  final String? description;
  final String? status;
  final String? learningDurationType;
  final DateTime? startDate;
  final dynamic endDate;
  final String? major;
  final TeacherModel? teacher;
  final int? studentCount;
  final int? lessonCount;

  RequestToCourseModel({
    this.id,
    this.name,
    this.image,
    this.description,
    this.status,
    this.learningDurationType,
    this.startDate,
    this.endDate,
    this.major,
    this.teacher,
    this.studentCount,
    this.lessonCount,
  });

  factory RequestToCourseModel.fromJson(Map<String, dynamic> json) => RequestToCourseModel(
    id: json["id"],
    name: json["name"],
    image: json["image"],
    description: json["description"],
    status: json["status"],
    learningDurationType: json["learningDurationType"],
    startDate: json["startDate"] == null ? null : AppUtils.fromUtcStringToVnTime(json["startDate"]),
    endDate: json["endDate"],
    major: json["major"],
    teacher: json["teacher"] == null ? null : TeacherModel.fromJson(json["teacher"]),
    studentCount: json["studentCount"],
    lessonCount: json["lessonCount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "description": description,
    "status": status,
    "learningDurationType": learningDurationType,
    "startDate": AppUtils.toOffsetDateTimeString(startDate),
    "endDate": endDate,
    "major": major,
    "teacher": teacher?.toJson(),
    "studentCount": studentCount,
    "lessonCount": lessonCount,
  };

  static List<RequestToCourseModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => RequestToCourseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

}