import 'package:lms/src/resource/model/model.dart';

class LessonModel {
  final String? id;
  final String? description;
  final int? order;
  final List<LessonMaterialModel>? lessonMaterials;
  final List<LessonQuizModel>? lessonQuizs;
  final List<ChapterModel>? chapters;
  ProgressModel? progress;

  LessonModel({
    this.id,
    this.description,
    this.order,
    this.lessonMaterials,
    this.lessonQuizs,
    this.chapters,
    this.progress,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {

    List<ChapterModel> chapters =
        json["chapter"] == null ? [] : List<ChapterModel>.from(json["chapter"]!.map((x) => ChapterModel.fromJson(x)));

    chapters.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    return LessonModel(
      id: json["id"],
      description: json["description"],
      order: json["order"],
      lessonMaterials: json["lessonMaterial"] == null
          ? []
          : List<LessonMaterialModel>.from(json["lessonMaterial"]!.map((x) => LessonMaterialModel.fromJson(x))),
      lessonQuizs: json["lessonQuiz"] == null
          ? []
          : List<LessonQuizModel>.from(json["lessonQuiz"]!.map((x) => LessonQuizModel.fromJson(x))),
      chapters: chapters,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "description": description,
        "order": order,
        "lessonMaterial": lessonMaterials == null ? [] : List<dynamic>.from(lessonMaterials!.map((x) => x.toJson())),
        "lessonQuiz": lessonQuizs == null ? [] : List<dynamic>.from(lessonQuizs!.map((x) => x.toJson())),
        "chapter": chapters == null ? [] : List<dynamic>.from(chapters!.map((x) => x.toJson())),
      };

  LessonModel copyWith({
    String? id,
    String? description,
    int? order,
    List<LessonMaterialModel>? lessonMaterials,
    List<LessonQuizModel>? lessonQuizs,
    List<ChapterModel>? chapters,
    ProgressModel? progress,
  }) {
    return LessonModel(
      id: id ?? this.id,
      description: description ?? this.description,
      order: order ?? this.order,
      lessonMaterials: lessonMaterials ?? this.lessonMaterials,
      lessonQuizs: lessonQuizs ?? this.lessonQuizs,
      chapters: chapters ?? this.chapters,
      progress: progress ?? this.progress,
    );
  }

  @override
  String toString() {
    return 'LessonModel{id: $id, description: $description, order: $order, lessonMaterials: ${lessonMaterials.toString()}, lessonQuizs: ${lessonQuizs.toString()}, chapters: ${chapters.toString()}, progress: ${progress.toString()}';
  }
}

class LessonMaterialModel {
  final String? id;
  final String? fileName;
  final String? path;

  LessonMaterialModel({
    this.id,
    this.fileName,
    this.path,
  });

  LessonMaterialModel copyWith({
    String? id,
    String? fileName,
    String? path,
  }) =>
      LessonMaterialModel(
        id: id ?? this.id,
        fileName: fileName ?? this.fileName,
        path: path ?? this.path,
      );

  factory LessonMaterialModel.fromJson(Map<String, dynamic> json) => LessonMaterialModel(
    id: json["id"],
    fileName: json["fileName"],
    path: json["path"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "fileName": fileName,
    "path": path,
  };
}

class LessonQuizModel {
  final String? id;
  final String? question;
  final String? option;
  final String? answer;

  LessonQuizModel({
    this.id,
    this.question,
    this.option,
    this.answer,
  });

  factory LessonQuizModel.fromJson(Map<String, dynamic> json) => LessonQuizModel(
        id: json["id"],
        question: json["question"],
        option: json["option"],
        answer: json["answer"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "question": question,
        "option": option,
        "answer": answer,
      };

  static List<LessonQuizModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => LessonQuizModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  List<String> getOptions() {
    return (option ?? '').split('; ');
  }

  String getOptionLetter(int index) {
    if (index >= 0 && index < getOptions().length) {
      return getOptions()[index].substring(0, 1);
    }
    return '';
  }

  @override
  String toString() {
    return 'LessonQuizModel{question: $question, option: $option, answer: $answer}';
  }
}
