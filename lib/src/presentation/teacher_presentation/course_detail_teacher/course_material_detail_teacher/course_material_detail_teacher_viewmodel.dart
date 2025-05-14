import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/lesson_model.dart';
import 'package:lms/src/utils/app_utils.dart';

class CourseMaterialDetailTeacherViewModel extends BaseViewModel {
  LessonMaterialModel material = Get.arguments['material'];

  init() async {
  }

  String get path => AppUtils.pathMediaToUrl(material.path);
}
