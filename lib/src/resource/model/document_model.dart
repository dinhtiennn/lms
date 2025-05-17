import 'package:lms/src/resource/model/model.dart';

class DocumentModel {
  final String? id;
  final String? title;
  final String? description;
  final String? status;
  final MajorModel? major;
  final String? fileName;
  final String? path;
  final TeacherModel? teacherModel;
  final DateTime? createdAt;

  DocumentModel({
    this.id,
    this.title,
    this.description,
    this.status,
    this.major,
    this.fileName,
    this.path,
    this.teacherModel,
    this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    status: json["status"],
    major: json["major"] == null ? null : MajorModel.fromJson(json["major"]),
    fileName: json["fileName"],
    path: json["path"],
    teacherModel: json["object"] == null ? null : TeacherModel.fromJson(json["object"]),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );

  static List<DocumentModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => DocumentModel.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "status": status,
    "major": major?.toJson(),
    "fileName": fileName,
    "path": path,
    "object": teacherModel?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
  };
  DocumentModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    MajorModel? major,
    String? fileName,
    String? path,
    TeacherModel? teacherModel,
    DateTime? createdAt,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      major: major ?? this.major,
      fileName: fileName ?? this.fileName,
      path: path ?? this.path,
      teacherModel: teacherModel ?? this.teacherModel,
      createdAt: createdAt ?? this.createdAt,
    );
  }

}