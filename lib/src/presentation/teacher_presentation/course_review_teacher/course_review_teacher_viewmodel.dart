import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:toastification/toastification.dart';
import 'package:lms/src/resource/enum/course_enum.dart';

class CourseReviewTeacherViewModel extends BaseViewModel {
  //hiển thị nút review
  bool? review;

  //hiển trạng thái join
  ValueNotifier<StatusJoin> joinStatus = ValueNotifier(StatusJoin.NOT_JOINED);
  ValueNotifier<CourseModel?> course = ValueNotifier(null);
  ValueNotifier<CourseDetailModel?> courseDetail = ValueNotifier(null);

  init() async {
    setCourse(Get.arguments['course']);
    review = Get.arguments['review'];
    loadCourseDetail();
  }

  void setCourse(CourseModel courseModel) {
    course.value = courseModel;
    course.notifyListeners();
  }

  void loadCourseDetail() async {
    NetworkState<CourseDetailModel> resultCourseDetail = await courseRepository.getCourseDetail(courseId: course.value?.id);
    if (resultCourseDetail.isSuccess && resultCourseDetail.result != null) {
      courseDetail.value = resultCourseDetail.result;
      courseDetail.notifyListeners();
    }
  }
}
