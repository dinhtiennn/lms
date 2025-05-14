
import 'package:lms/src/resource/model/model.dart';

sealed class CurrentContent {}

class MaterialContent extends CurrentContent {
  final LessonMaterialModel material;

  MaterialContent(this.material);

  @override
  String toString() {
    return 'MaterialContent{material: ${material.toString()}';
  }
}

class QuizContent extends CurrentContent {
  final List<LessonQuizModel> quizs;

  QuizContent(this.quizs);

  @override
  String toString() {
    return 'QuizContent{quizs: ${quizs.toString()}';
  }
}

class ChapterContent extends CurrentContent {
  final ChapterModel chapter;

  ChapterContent(this.chapter);

  @override
  String toString() {
    return 'ChapterContent{chapter: ${chapter.toString()}';
  }
}
