import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:toastification/toastification.dart';
import 'package:lms/src/resource/enum/course_enum.dart';

class CourseReviewViewModel extends BaseViewModel {

  //hiển thị nút review
  bool? review;

  //hiển trạng thái join
  ValueNotifier<StatusJoin> joinStatus = ValueNotifier(StatusJoin.NOT_JOINED);
  ValueNotifier<CourseModel?> course = ValueNotifier(null);

  init() async {
    setCourse(Get.arguments['course']);
    review = Get.arguments['review'];
    await getStatusJoin(course.value!);
  }

  void setCourse(CourseModel courseModel) {
    course.value = courseModel;
    course.notifyListeners();
  }

  Future<void> joinCourse() async {
    setLoading(true);
    NetworkState<bool> resultJoinCourse =
        await courseRepository.joinCourse(idCourse: course.value?.id);
    setLoading(false);

    if (resultJoinCourse.isSuccess &&
        resultJoinCourse.result != null &&
        resultJoinCourse.result!) {
      // Kiểm tra nếu trước đó là REJECTED
      final wasRejected = joinStatus.value == StatusJoin.REJECTED;

      if (course.value?.status?.contains('PUBLIC') ?? false) {
        showToast(
            title: 'Tham gia khóa học thành công!',
            type: ToastificationType.success);
        Get.offAndToNamed(Routers.courseDetail,
            arguments: {'course': course.value});
      } else {
        showToast(
            title: wasRejected
                ? 'Đã gửi lại yêu cầu tham gia!'
                : 'Gửi yêu cầu tham gia khóa học thành công!',
            type: ToastificationType.success);
      }
      await getStatusJoin(course.value!);
    } else {
      showToast(
          title: 'Lỗi ${resultJoinCourse.message}, vui lòng thử lại sau!',
          type: ToastificationType.error);
    }
  }

  void allRequest() {
    Get.toNamed(Routers.allRequestJoinCourseByStudent);
  }

  Future<void> getStatusJoin(CourseModel course) async {
    NetworkState<String> resultStatusJoin =
        await courseRepository.getStatusJoin(courseId: course.id);
    if (resultStatusJoin.isSuccess && resultStatusJoin.result != null) {
      final status = resultStatusJoin.result!;
      // Chuyển đổi giá trị String từ API sang enum StatusJoin
      try {
        switch (status) {
          case "APPROVED":
            joinStatus.value = StatusJoin.APPROVED;
            break;
          case "PENDING":
            joinStatus.value = StatusJoin.PENDING;
            break;
          case "REJECTED":
            joinStatus.value = StatusJoin.REJECTED;
            break;
          default:
            joinStatus.value = StatusJoin.NOT_JOINED;
            break;
        }
      } catch (e) {
        logger.e("Lỗi khi chuyển đổi trạng thái: $e");
        joinStatus.value = StatusJoin.NOT_JOINED;
      }
      joinStatus.notifyListeners();
    }
  }

  // Các hàm xử lý cho các trạng thái StatusJoin
  void handleApproved() {
    logger.i("Đã được chấp nhận - Trạng thái: ${joinStatus.value}");
    Get.toNamed(Routers.courseDetail, arguments: {'course': course.value});
  }

  void handlePending() {
    logger.i("Đang chờ duyệt - Trạng thái: ${joinStatus.value}");
    showToast(
        title: 'Yêu cầu của bạn đang được xem xét',
        type: ToastificationType.info);
  }

  void handleRejected() {
    logger.i("Bị từ chối - Trạng thái: ${joinStatus.value}");
    showToast(
        title: 'Đang gửi yêu cầu tham gia lại...',
        type: ToastificationType.info);
    joinCourse();
  }

  void handleNotJoined() {
    logger.i("Chưa tham gia - Trạng thái: ${joinStatus.value}");
    joinCourse();
  }
}
