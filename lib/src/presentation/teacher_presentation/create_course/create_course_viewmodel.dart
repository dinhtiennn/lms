import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:toastification/toastification.dart';

class CreateCourseViewModel extends BaseViewModel {
  var formKey = GlobalKey<FormState>();
  TextEditingController courseNameController = TextEditingController();
  TextEditingController courseDescriptionController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  ValueNotifier<List<MajorModel>?> majors = ValueNotifier(null);
  ValueNotifier<StatusOption?> statusSelected = ValueNotifier(StatusOption(Status.PUBLIC, 'Công khai', 'PUBLIC'));
  ValueNotifier<MajorModel?> majorSelected = ValueNotifier(null);

  //biến quản lý picker
  ImagePicker picker = ImagePicker();
  ValueNotifier<XFile?> imageCoursePicker = ValueNotifier(null);

  init() async {
    await _loadMajor();
  }

  void pickCourseImage() async {
    imageCoursePicker.value = await picker.pickImage(source: ImageSource.gallery);
    notifyListeners();
  }

  List<StatusOption> statusOptions = [
    StatusOption(Status.PUBLIC, 'Công khai', 'PUBLIC'),
    StatusOption(Status.PRIVATE, 'Riêng tư', 'PRIVATE'),
    StatusOption(Status.REQUEST, 'Yêu cầu tham gia', 'REQUEST'),
  ];

  List<LearningDurationTypeOption> learningDurationOptions = [
    LearningDurationTypeOption(LearningDurationType.LIMITED, 'Có thời hạn', 'LIMITED'),
    LearningDurationTypeOption(LearningDurationType.UNLIMITED, 'Không có thời hạn', 'UNLIMITED'),
  ];

  String getStatusLabel(Status status) => statusOptions.firstWhere((e) => e.value == status).label;

  String getLearningDurationTypeLabel(LearningDurationType type) =>
      learningDurationOptions.firstWhere((e) => e.value == type).apiValue;

  void addCourse() async {
    String learningDurationTypeString = getLearningDurationTypeLabel(
        endDateController.text.isEmpty ? LearningDurationType.UNLIMITED : LearningDurationType.LIMITED);
    setLoading(false);
    if (majorSelected.value == null) {
      showToast(title: 'Vui lòng chọn ngành học');
      return;
    }
    NetworkState<CourseModel> resultAddCourse = await courseRepository.addCourse(
      name: courseNameController.text,
      description: courseDescriptionController.text,
      status: statusSelected.value?.apiValue,
      startDate: AppUtils.formatDateToISO(startDateController.text),
      endDate: AppUtils.formatDateToISO(endDateController.text),
      majorId: majorSelected.value?.id,
      learningDurationType: learningDurationTypeString,
    );
    setLoading(false);
    if (resultAddCourse.isSuccess && resultAddCourse.result != null) {
      if (imageCoursePicker.value != null) {
        NetworkState resultUploadImage =
            await courseRepository.uploadImage(id: resultAddCourse.result?.id, image: imageCoursePicker.value);
        if (resultUploadImage.isError) {
          showToast(title: 'Cập nhật ảnh thất bại, vui lòng thử lại sau!', type: ToastificationType.error);
          await Future.delayed(const Duration(seconds: 2));
        }
      }
      showToast(title: 'Thêm khóa học thành công');
      await Future.delayed(const Duration(seconds: 2));
      if (Get.isRegistered<HomeTeacherViewModel>()) {
        Get.find<HomeTeacherViewModel>().refresh();
        await Future.delayed(const Duration(seconds: 1));
      }
      Get.back();
    }
  }

  Future<void> _loadMajor() async {
    NetworkState<List<MajorModel>> resultMajor = await majorRepository.getAllMajor();
    setLoading(false);
    if (resultMajor.isSuccess && resultMajor.result != null) {
      majors.value = resultMajor.result ?? [];
      majors.notifyListeners();
    }
  }

  void setMajor(MajorModel major) {
    majorSelected.value = major;
    majorSelected.notifyListeners();
  }
}
