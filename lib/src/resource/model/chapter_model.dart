import 'package:lms/src/resource/resource.dart';

class ChapterModel {
  final String? id;
  final String? name;
  final String? path;
  final String? type;
  final int? order;
  final ProgressModel? progress;

  ChapterModel({
    this.id,
    this.name,
    this.path,
    this.type,
    this.order,
    this.progress,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) => ChapterModel(
    id: json["id"],
    name: json["name"],
    path: json["path"],
    type: json["type"],
    order: json["order"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "path": path,
    "type": type,
    "order": order,
  };
  ChapterModel copyWith({
    String? id,
    String? name,
    String? path,
    String? type,
    int? order,
    ProgressModel? progress,
  }) {
    return ChapterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      path: path ?? this.path,
      type: type ?? this.type,
      progress: progress ?? this.progress,
    );
  }

  @override
  String toString() {
    return 'ChapterModel{id: $id, name: $name, path: $path, type: $type, order: $order, progress: ${progress?.isCompleted}';
  }
}