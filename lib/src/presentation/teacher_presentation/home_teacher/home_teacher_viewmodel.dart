import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:lms/src/utils/utils.dart';

class HomeTeacherViewModel extends BaseViewModel {
  ValueNotifier<TeacherModel?> teacher = ValueNotifier<TeacherModel?>(null);
  ValueNotifier<List<CourseModel>?> courses = ValueNotifier(null);
  ValueNotifier<bool> isLoadingMore = ValueNotifier(false);
  int pageNumber = 0;
  bool hasMoreData = true;
  int pageSize = 4;

  init() async {
    await loadMyCourse();
    await loadTeacherInfo();
  }

  void refresh() {
    pageNumber = 0;
    hasMoreData = true;
    loadMyCourse();
  }

  void createCourse() {
    Get.toNamed(Routers.createCourse);
  }

  Future<void> loadTeacherInfo() async {
    teacher.value = AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson);
    teacher.notifyListeners();
  }

  Future<void> loadMyCourse({bool isLoadMore = false}) async {
    if (isLoadingMore.value || !hasMoreData) return;

    if (pageNumber == 0) {
      setLoading(true);
    } else {
      isLoadingMore.value = true;
      isLoadingMore.notifyListeners();
    }

    NetworkState<List<CourseModel>> result = await courseRepository.getCoursesByTeacher(
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
    setLoading(false);
    if (result.isSuccess && result.result != null) {
      if (pageNumber == 0) {
        courses.value = result.result;
      } else {
        List<CourseModel> currentCourses = List.from(courses.value ?? []);
        currentCourses.addAll(result.result!);
        courses.value = currentCourses;
      }

      hasMoreData = result.result!.length >= pageSize;
      pageNumber++;
      courses.notifyListeners();
    }

    if (pageNumber == 0) {
      setLoading(false);
    } else {
      isLoadingMore.value = false;
      isLoadingMore.notifyListeners();
    }
  }

  void courseDetail(CourseModel course){
    Get.toNamed(Routers.courseDetailTeacher, arguments: {'course' : course});
  }

  void search() {
    Get.toNamed(Routers.searchTeacher);
  }

  void refreshTeacher() {
    TeacherModel? teacher = AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson);
    if(teacher == null){
      showToast(title: 'Lỗi hệ thống vui lòng thử lại sau');
      Get.offAllNamed(Routers.login);
    }
    AppPrefs.setUser<TeacherModel>(teacher);
    this.teacher.value = teacher!.copyWith(avatar: AppUtils.pathMediaToUrlAndRamdomParam(teacher.avatar));
  }

}
