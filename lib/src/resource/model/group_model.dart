import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_utils.dart';

class GroupModel {
  final String? id;
  final String? name;
  final String? description;
  final TeacherModel? teacher;

  GroupModel({
    this.id,
    this.name,
    this.description,
    this.teacher,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        teacher: json["teacher"] == null ? null : TeacherModel.fromJson(json["teacher"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "teacher": teacher?.toJson(),
      };

  static List<GroupModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => GroupModel.fromJson(json)).toList();
  }
}

class PostModel {
  final String? id;
  final String? title;
  final String? text;
  final DateTime? createdAt;
  final List<FileElement>? files;

  PostModel({
    this.id,
    this.title,
    this.text,
    this.createdAt,
    this.files,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        id: json["id"],
        title: json["title"],
        text: json["text"],
        createdAt: json["createdAt"] == null ? null : AppUtils.fromUtcStringToVnTime(json["createdAt"]),
        files: json["files"] == null ? [] : List<FileElement>.from(json["files"]!.map((x) => FileElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "text": text,
        "createdAt": AppUtils.toOffsetDateTimeString(createdAt),
        "files": files == null ? [] : List<dynamic>.from(files!.map((x) => x.toJson())),
      };

  static List<PostModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => PostModel.fromJson(json)).toList();
  }
}

class FileElement {
  final String? id;
  final String? fileName;
  final String? fileType;
  final String? fileUrl;

  FileElement({
    this.id,
    this.fileName,
    this.fileType,
    this.fileUrl,
  });

  factory FileElement.fromJson(Map<String, dynamic> json) => FileElement(
        id: json["id"],
        fileName: json["fileName"],
        fileType: json["fileType"],
        fileUrl: json["fileUrl"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fileName": fileName,
        "fileType": fileType,
        "fileUrl": fileUrl,
      };
}

class TestDetailModel {
  final String? id;
  final String? title;
  final String? description;
  final DateTime? createdAt;
  final DateTime? startedAt;
  final DateTime? expiredAt;
  final List<TestQuestionRequestModel>? questions;

  TestDetailModel({
    this.id,
    this.title,
    this.description,
    this.createdAt,
    this.startedAt,
    this.expiredAt,
    this.questions,
  });

  factory TestDetailModel.fromJson(Map<String, dynamic> json) => TestDetailModel(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        startedAt: json["startedAt"] == null ? null : AppUtils.fromUtcStringToVnTime(json["startedAt"]),
        createdAt: json["createdAt"] == null ? null : AppUtils.fromUtcStringToVnTime(json["createdAt"]),
        expiredAt: json["expiredAt"] == null ? null : AppUtils.fromUtcStringToVnTime(json["expiredAt"]),
        questions: json["questions"] == null
            ? []
            : List<TestQuestionRequestModel>.from(json["questions"]!.map((x) => TestQuestionRequestModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "startedAt": AppUtils.toOffsetDateTimeString(startedAt),
        "createdAt": AppUtils.toOffsetDateTimeString(createdAt),
        "expiredAt": AppUtils.toOffsetDateTimeString(expiredAt),
        "questions": questions == null ? [] : List<dynamic>.from(questions!.map((x) => x.toJson())),
      };
}

class TestQuestionRequestModel {
  final String? id;
  final int? point;
  final String? content;
  final String? type;
  final String? options;
  final String? correctAnswers;

  TestQuestionRequestModel({
    this.id,
    this.point,
    this.content,
    this.type,
    this.options,
    this.correctAnswers,
  });

  factory TestQuestionRequestModel.fromJson(Map<String, dynamic> json) => TestQuestionRequestModel(
        id: json["id"],
        point: json["point"],
        content: json["content"],
        type: json["type"],
        options: json["options"],
        correctAnswers: json["correctAnswers"],
      );

  Map<String, dynamic> toJson() => {
        "point": point,
        "content": content,
        "type": type,
        "options": options,
        "correctAnswers": correctAnswers,
      };

  static List<TestQuestionRequestModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => TestQuestionRequestModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  String toString() {
    return 'TestQuestionRequestModel{id: $id, point: $point, content: $content, type: $type, options: $options, correctAnswers: $correctAnswers}';
  }
}

class TestInGroupRequestModel {
  final String groupId;
  final String title;
  final String? description;
  final DateTime? expiredAt;
  final List<TestQuestionRequestModel> listQuestionRequest;

  TestInGroupRequestModel({
    required this.groupId,
    required this.title,
    this.description,
    required this.expiredAt,
    required this.listQuestionRequest,
  });

  factory TestInGroupRequestModel.fromJson(Map<String, dynamic> json) {
    return TestInGroupRequestModel(
      groupId: json['groupId'],
      title: json['title'],
      description: json['description'],
      expiredAt: json['expiredAt'] == null ? null : AppUtils.fromUtcStringToVnTime(json['expiredAt']),
      listQuestionRequest: TestQuestionRequestModel.listFromJson(json['listQuestionRequest']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'title': title,
      'description': description,
      'expiredAt': AppUtils.toOffsetDateTimeString(expiredAt),
      'listQuestionRequest': listQuestionRequest.map((e) => e.toJson()).toList(),
    };
  }

  static List<TestInGroupRequestModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => TestInGroupRequestModel.fromJson(json as Map<String, dynamic>)).toList();
  }
}

class TestModel {
  final String? id;
  final String? title;
  final String? description;
  final DateTime? startedAt;
  final DateTime? createdAt;
  final DateTime? expiredAt;
  final bool? isSuccess;

  TestModel({
    this.id,
    this.title,
    this.description,
    this.startedAt,
    this.createdAt,
    this.expiredAt,
    this.isSuccess,
  });

  factory TestModel.fromJson(Map<String, dynamic> json) => TestModel(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        startedAt: json["startedAt"] == null ? null : AppUtils.fromUtcStringToVnTime(json["startedAt"]),
        createdAt: json["createdAt"] == null ? null : AppUtils.fromUtcStringToVnTime(json["createdAt"]),
        expiredAt: json["expiredAt"] == null ? null : AppUtils.fromUtcStringToVnTime(json["expiredAt"]),
        isSuccess: json["isSuccess"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "startedAt": AppUtils.toOffsetDateTimeString(startedAt),
        "createdAt": AppUtils.toOffsetDateTimeString(createdAt),
        "expiredAt": AppUtils.toOffsetDateTimeString(expiredAt),
        "isSuccess": isSuccess,
      };

  static List<TestModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => TestModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  TestModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startedAt,
    DateTime? createdAt,
    DateTime? expiredAt,
    bool? isSuccess,
  }) {
    return TestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startedAt: startedAt ?? this.startedAt,
      createdAt: createdAt ?? this.createdAt,
      expiredAt: expiredAt ?? this.expiredAt,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  String toString() {
    return 'TestModel{id: $id, title: $title, description: $description, startedAt: $startedAt, createdAt: $createdAt, expiredAt: $expiredAt, isSuccess: $isSuccess}';
  }
}

class AnswerModel {
  final String questionId;
  final String answer;

  AnswerModel({
    required this.questionId,
    required this.answer,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      questionId: json['questionId'] as String,
      answer: json['answer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answer': answer,
    };
  }

  AnswerModel copyWith({
    String? questionId,
    String? answer,
  }) {
    return AnswerModel(
      questionId: questionId ?? this.questionId,
      answer: answer ?? this.answer,
    );
  }

  @override
  String toString() {
    return 'AnswerModel{questionId: $questionId, answer: $answer}';
  }
}

class TestResultModel {
  final String? id;
  final StudentModel? student;
  final TestModel? testInGroup;
  final int? totalCorrect;
  final double? score;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final List<TestStudentAnswer>? testStudentAnswer;

  TestResultModel({
    this.id,
    this.student,
    this.testInGroup,
    this.totalCorrect,
    this.score,
    this.startedAt,
    this.submittedAt,
    this.testStudentAnswer,
  });

  factory TestResultModel.fromJson(Map<String, dynamic> json) => TestResultModel(
        id: json["id"],
        student: json["student"] == null ? null : StudentModel.fromJson(json["student"]),
        testInGroup: json["testInGroup"] == null ? null : TestModel.fromJson(json["testInGroup"]),
        totalCorrect: json["totalCorrect"],
        score: json["score"],
        startedAt: json["startedAt"] == null ? null : AppUtils.fromUtcStringToVnTime(json["startedAt"]),
        submittedAt: json["submittedAt"] == null ? null : AppUtils.fromUtcStringToVnTime(json["submittedAt"]),
        testStudentAnswer:
            json["testStudentAnswer"] == null ? [] : TestStudentAnswer.listFromJson(json["testStudentAnswer"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "student": student?.toJson(),
        "testInGroup": testInGroup?.toJson(),
        "totalCorrect": totalCorrect,
        "score": score,
        "startedAt": AppUtils.toOffsetDateTimeString(startedAt),
        "submittedAt": AppUtils.toOffsetDateTimeString(submittedAt),
        "testStudentAnswer":
            testStudentAnswer == null ? [] : List<dynamic>.from(testStudentAnswer!.map((x) => x.toJson())),
      };
}

class TestStudentAnswer {
  final String? id;
  final TestQuestionRequestModel? testQuestion;
  final String? answer;
  final bool? correct;

  TestStudentAnswer({
    this.id,
    this.testQuestion,
    this.answer,
    this.correct,
  });

  factory TestStudentAnswer.fromJson(Map<String, dynamic> json) => TestStudentAnswer(
        id: json["id"],
        testQuestion: json["testQuestion"] == null ? null : TestQuestionRequestModel.fromJson(json["testQuestion"]),
        answer: json["answer"],
        correct: json["correct"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "testQuestion": testQuestion?.toJson(),
        "answer": answer,
        "correct": correct,
      };

  static List<TestStudentAnswer> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => TestStudentAnswer.fromJson(json as Map<String, dynamic>)).toList();
  }
}

class TestResultView {
  final String? id;
  final StudentModel? student;
  final TestDetailModel? testInGroup;
  final int? totalCorrect;
  final double? score;
  final DateTime? startedAt;
  final DateTime? submittedAt;

  TestResultView({
    this.id,
    this.student,
    this.testInGroup,
    this.totalCorrect,
    this.score,
    this.startedAt,
    this.submittedAt,
  });

  factory TestResultView.fromJson(Map<String, dynamic> json) => TestResultView(
        id: json["id"],
        student: json["student"] == null ? null : StudentModel.fromJson(json["student"]),
        testInGroup: json["testInGroup"] == null ? null : TestDetailModel.fromJson(json["testInGroup"]),
        totalCorrect: json["totalCorrect"],
        score: json["score"],
        startedAt: json["startedAt"] == null ? null : AppUtils.fromUtcStringToVnTime(json["startedAt"]),
        submittedAt: json["submittedAt"] == null ? null : AppUtils.fromUtcStringToVnTime(json["submittedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "student": student?.toJson(),
        "testInGroup": testInGroup?.toJson(),
        "totalCorrect": totalCorrect,
        "score": score,
        "startedAt": startedAt?.toIso8601String(),
        "submittedAt": submittedAt?.toIso8601String(),
      };

  static List<TestResultView> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => TestResultView.fromJson(json as Map<String, dynamic>)).toList();
  }
}
