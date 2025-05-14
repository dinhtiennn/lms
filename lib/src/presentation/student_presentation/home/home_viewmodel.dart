import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/utils.dart';

class HomeViewModel extends BaseViewModel {
  ValueNotifier<StudentModel?> student = ValueNotifier(null);
  ValueNotifier<List<CourseModel>> myCourse = ValueNotifier([]);
  ValueNotifier<List<CourseModel>> courseOfMajor = ValueNotifier([]);
  ValueNotifier<bool> isLoadingMorePublicCourses = ValueNotifier(false);
  int currentPagePublicCourses = 0;

  //flag loadMore
  bool loadMore = true;

  init() async {
    refreshStudent();
    await getMyCourses();
    await getPublicCourses();
  }

  void setLoadMore(bool load) {
    loadMore = load;
  }

  void refreshStudent() {
    student.value = AppPrefs.getUser<StudentModel>(StudentModel.fromJson);
    student.notifyListeners();
  }

  Future<void> getMyCourses() async {
    NetworkState<List<CourseModel>> resultCourses =
        await courseRepository.myCourses();
    if (resultCourses.isSuccess && resultCourses.result != null) {
      myCourse.value = resultCourses.result!;
      await Future.wait(myCourse.value.map((course) async {
        course.progress = await _loadCourseProgressDetail(course.id ?? '');
        logger.e(course.progress);
      }));
      myCourse.notifyListeners();
    }
  }

  Future<void> getPublicCourses({int pageSize = 10, int pageNumber = 0}) async {
    if (isLoadingMorePublicCourses.value) {
      return;
    }

    if (!loadMore) {
      return;
    }

    if (pageNumber == 0) {
      setLoading(true);
    } else {
      isLoadingMorePublicCourses.value = true;
      isLoadingMorePublicCourses.notifyListeners();
    }

    NetworkState<List<CourseModel>> resultCoursesOfMajor =
        await courseRepository.courseOfMajorFirst(
            pageSize: pageSize, pageNumber: pageNumber);

    if (resultCoursesOfMajor.isSuccess && resultCoursesOfMajor.result != null) {
      if ((resultCoursesOfMajor.result?.isEmpty ?? true)) {
        loadMore = false;
      }
      Set<String?> myCourseIds = myCourse.value.map((e) => e.id).toSet();

      List<CourseModel> filteredCourses = resultCoursesOfMajor.result!
          .where((course) => !myCourseIds.contains(course.id))
          .toList();

      if (pageNumber == 0) {
        courseOfMajor.value = filteredCourses;
      } else {
        List<CourseModel> currentCourses = List.from(courseOfMajor.value);
        currentCourses.addAll(filteredCourses);
        courseOfMajor.value = currentCourses;
      }

      courseOfMajor.notifyListeners();
      currentPagePublicCourses = pageNumber;
    }

    if (pageNumber == 0) {
      setLoading(false);
    } else {
      isLoadingMorePublicCourses.value = false;
      isLoadingMorePublicCourses.notifyListeners();
    }
  }

  Future<int> _loadCourseProgressDetail(String courseId) async {
    NetworkState<CourseDetailModel> resultCourseDetail =
        await courseRepository.getCourseDetail(courseId: courseId);

    if (!resultCourseDetail.isSuccess ||
        resultCourseDetail.result == null ||
        resultCourseDetail.result?.lesson == null ||
        resultCourseDetail.result!.lesson!.isEmpty) {
      return 0;
    }

    int completedLessons = 0;
    int totalLessons = resultCourseDetail.result!.lesson!.length;

    for (final lesson in resultCourseDetail.result!.lesson!) {
      NetworkState<ProgressModel> progressResult =
          await courseRepository.getProgressLesson(lessonId: lesson.id);
      if (progressResult.isSuccess &&
          progressResult.result != null &&
          progressResult.result!.isCompleted == true) {
        completedLessons++;
      }
    }

    return ((completedLessons * 100) ~/ totalLessons);
  }

  void loadMorePublicCourses() {
    if (!isLoadingMorePublicCourses.value) {
      getPublicCourses(pageNumber: currentPagePublicCourses + 1);
    }
  }

  void courseDetail(CourseModel course) {
    Get.toNamed(Routers.courseDetail, arguments: {'course': course});
  }

  void courseReviews() {
    Get.toNamed(Routers.courseReview);
  }

  void search() {
    Get.toNamed(Routers.search);
  }

  void toListCourseWatching() {
    if (Get.isRegistered<NavigationViewModel>()) {
      Get.find<NavigationViewModel>().setIndex(1);
    }
  }

  void previewCourse(CourseModel courseModel) {
    Get.toNamed(Routers.courseReview,
        arguments: {'course': courseModel, 'join': true});
  }
}
