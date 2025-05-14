import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/lesson_model.dart';

class CourseQuizDetailTeacherViewModel extends BaseViewModel {
  LessonModel lesson = Get.arguments['lesson'];

  init() async {}
}
