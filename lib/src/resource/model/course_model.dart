import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:logger/logger.dart';

class CourseModel {
  final String? id;
  final String? name;
  final String? image;
  final String? description;
  final String? status;
  final String? learningDurationType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? major;
  final String? feeType;
  final double? price;
  final TeacherModel? teacher;
  final int? studentCount;
  final int? chapterCount;
  int? progress;

  CourseModel({
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
    this.feeType,
    this.price,
    this.studentCount,
    this.chapterCount,
    this.progress,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json["id"],
      name: json["name"],
      image: AppUtils.pathMediaToUrlAndRamdomParam(json["image"]),
      description: json["description"],
      status: json["status"],
      learningDurationType: json["learningDurationType"],
      startDate: json["startDate"] == null ? null : AppUtils.fromUtcStringToVnTime(json["startDate"]),
      endDate: json["endDate"] == null ? null : AppUtils.fromUtcStringToVnTime(json["endDate"]),
      major: json["major"],
      teacher: json["teacher"] == null ? null : TeacherModel.fromJson(json["teacher"]),
      studentCount: json["studentCount"],
      chapterCount: json["chapterCount"],
      price: json["price"],
      feeType: json["feeType"],
    );
  }

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
        "chapterCount": chapterCount,
      };

  static List<CourseModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => CourseModel.fromJson(json)).toList();
  }

  CourseModel copyWith({
    String? name,
    String? image,
    String? description,
    String? status,
    String? learningDurationType,
    DateTime? startDate,
    DateTime? endDate,
    String? major,
    TeacherModel? teacher,
    int? studentCount,
    int? chapterCount,
    int? progress,
  }) {
    return CourseModel(
      name: name ?? this.name,
      image: image ?? this.image,
      description: description ?? this.description,
      status: status ?? this.status,
      learningDurationType: learningDurationType ?? this.learningDurationType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      major: major ?? this.major,
      teacher: teacher ?? this.teacher,
      studentCount: studentCount ?? this.studentCount,
      chapterCount: chapterCount ?? this.chapterCount,
      progress: progress ?? this.progress,
    );
  }

  @override
  String toString() {
    return 'CourseModel{id: $id, name: $name, image: $image, description: $description, status: $status, learningDurationType: $learningDurationType, startDate: $startDate, endDate: $endDate, major: $major, teacher: $teacher, studentCount: $studentCount, lessonCount: $chapterCount, progress: $progress}';
  }
}

class CourseDetailModel {
  final String? id;
  final String? name;
  final String? image;
  final String? description;
  final String? status;
  final String? learningDurationType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? major;
  final String? feeType;
  final double? price;
  final TeacherModel? teacher;
  List<LessonModel>? lesson;

  CourseDetailModel({
    this.id,
    this.name,
    this.image,
    this.description,
    this.status,
    this.learningDurationType,
    this.startDate,
    this.endDate,
    this.major,
    this.feeType,
    this.price,
    this.teacher,
    this.lesson,
  });

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    List<LessonModel> lessons =
        json["lesson"] == null ? [] : List<LessonModel>.from(json["lesson"]!.map((x) => LessonModel.fromJson(x)));

    // Sắp xếp theo thứ tự tăng dần của lesson.order
    lessons.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    return CourseDetailModel(
      id: json["id"],
      name: json["name"],
      image: AppUtils.pathMediaToUrlAndRamdomParam(json["image"]),
      description: json["description"],
      status: json["status"],
      feeType: json["feeType"],
      price: json["price"],
      learningDurationType: json["learningDurationType"],
      startDate: json["startDate"] == null ? null : AppUtils.fromUtcStringToVnTime(json["startDate"]),
      endDate: json["endDate"] == null ? null : AppUtils.fromUtcStringToVnTime(json["endDate"]),
      major: json["major"],
      teacher: json["teacher"] == null ? null : TeacherModel.fromJson(json["teacher"]),
      lesson: lessons,
    );
  }

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
        "lesson": lesson == null ? [] : List<dynamic>.from(lesson!.map((x) => x.toJson())),
      };

  CourseDetailModel copyWith({
    String? id,
    String? name,
    String? image,
    String? description,
    String? status,
    String? learningDurationType,
    DateTime? startDate,
    dynamic endDate,
    String? major,
    TeacherModel? teacher,
    List<LessonModel>? lesson,
  }) {
    return CourseDetailModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      description: description ?? this.description,
      status: status ?? this.status,
      learningDurationType: learningDurationType ?? this.learningDurationType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      major: major ?? this.major,
      teacher: teacher ?? this.teacher,
      lesson: lesson ?? this.lesson,
    );
  }

  @override
  String toString() {
    return 'CourseDetailModel{id: $id, name: $name, image: $image, description: $description, status: $status, learningDurationType: $learningDurationType, startDate: $startDate, endDate: $endDate, major: $major, teacher: $teacher, lesson: $lesson}';
  }
}

//class để quản lý tạo- chỉnh sửa khóa học
class StatusOption {
  final Status value;
  final String label;
  final String apiValue;

  const StatusOption(this.value, this.label, this.apiValue);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StatusOption && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class LearningDurationTypeOption {
  final LearningDurationType value;
  final String label;
  final String apiValue;

  const LearningDurationTypeOption(this.value, this.label, this.apiValue);
}

class FeeStatusOption {
  final FeeStatusType value;
  final String label;
  final String apiValue;

  const FeeStatusOption(this.value, this.label, this.apiValue);
}
