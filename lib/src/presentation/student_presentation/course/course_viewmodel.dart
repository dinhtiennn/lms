import 'package:flutter/material.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:get/get.dart';

class CourseViewModel extends BaseViewModel {
  ValueNotifier<List<CourseModel>> myCourse = ValueNotifier([]);
  ValueNotifier<bool> isLoadingMoreCourses = ValueNotifier(false);

  // Số trang hiện tại và trạng thái tải
  int currentPage = 0;

  init() async {
    // Đặt lại _currentPage mỗi khi widget được tạo mới
    currentPage = 0;

    getMyCourse();
  }

  void loadMoreMyCourses() {
    if (!isLoadingMoreCourses.value) {
      getMyCourse(pageNumber: currentPage + 1);
    }
  }

  void getMyCourse({int pageNumber = 0, int pageSize = 20}) async {
    if (isLoadingMoreCourses.value) {
      return;
    }

    if (pageNumber == 0) {
      setLoading(true);
    } else {
      isLoadingMoreCourses.value = true;
      isLoadingMoreCourses.notifyListeners();
    }

    NetworkState<List<CourseModel>> resultCourses = await courseRepository
        .myCourses(pageSize: pageSize, pageNumber: pageNumber);

    if (resultCourses.isSuccess && resultCourses.result != null) {
      // Gán danh sách khóa học mới trước
      List<CourseModel> newCourses = resultCourses.result!;

      // Cập nhật myCourse.value trước
      if (pageNumber == 0) {
        myCourse.value = newCourses;
      } else {
        List<CourseModel> currentCourses = List.from(myCourse.value);
        currentCourses.addAll(newCourses);
        myCourse.value = currentCourses;
      }

      // Cập nhật progress cho các khóa học mới
      for (int i = 0; i < newCourses.length; i++) {
        final course = newCourses[i];
        int progress = await _loadCourseProgressDetail(course.id ?? '');
        // Cập nhật progress và notify nếu có thay đổi
        if (course.progress != progress) {
          course.progress = progress;
          myCourse.notifyListeners();
        }
      }

      currentPage = pageNumber;
    }

    if (pageNumber == 0) {
      setLoading(false);
    } else {
      isLoadingMoreCourses.value = false;
      isLoadingMoreCourses.notifyListeners();
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
}
