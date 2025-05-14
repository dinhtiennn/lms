import 'package:lms/src/resource/model/major_model.dart';

class StudentModel {
  final String? id;
  final String? fullName;
  final String? email;
  final MajorModel? major;
  final dynamic description;
  final String? avatar;

  StudentModel({
    this.id,
    this.fullName,
    this.email,
    this.major,
    this.description,
    this.avatar,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json["id"],
    fullName: json["fullName"],
    email: json["email"],
    major: json["major"] == null ? null : MajorModel.fromJson(json["major"]),
    description: json["description"],
    avatar: json["avatar"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "fullName": fullName,
    "email": email,
    "major": major?.toJson(),
    "description": description,
    "avatar": avatar,
  };

  StudentModel copyWith({
    String? id,
    String? fullName,
    String? email,
    MajorModel? major,
    String? description,
    String? avatar,
  }) {
    return StudentModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      major: major ?? this.major,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
    );
  }

  @override
  String toString() {
    return 'StudentModel{id: $id, fullName: $fullName, email: $email, major: $major, description: $description, avatar: $avatar}';
  }

  static List<StudentModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => StudentModel.fromJson(json)).toList();
  }
}