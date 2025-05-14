import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/utils.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:toastification/toastification.dart';

class EditProfileTeacherViewModel extends BaseViewModel {
  ValueNotifier<TeacherModel?> teacher = ValueNotifier(null);
  final ImagePicker picker = ImagePicker();
  XFile? avatar;

  init() async {
    refreshTeacher();
  }

  void pickImageAvatar({
    bool camera = false,
    required Future<bool> Function() confirmDialog,
  }) async {
    try {
      final pickedImageFile = await picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
      );

      if (pickedImageFile == null) return;

      final bool saveConfirmed = await confirmDialog();
      final String? teacherId = teacher.value?.id;

      if (!saveConfirmed) return;
      if (teacherId == null || teacherId.isEmpty) {
        toast('lỗi không xác định user');
        return;
      }

      setLoading(true);
      NetworkState resultUpdateAvatar = await teacherRepository.updateAvatar(
        id: teacherId,
        avatar: pickedImageFile,
      );
      setLoading(false);
      if (resultUpdateAvatar.isSuccess) {
        String avatarWithParam =
            AppUtils.pathMediaToUrlAndRamdomParam(resultUpdateAvatar.result);
        refreshUser(avatarWithParam);
        showToast(
          title: 'Thay đổi ảnh đại diện thành công'.tr,
          type: ToastificationType.success,
        );
        refreshTeacher();

        if (Get.isRegistered<HomeTeacherViewModel>()) {
          final homeVM = Get.find<HomeTeacherViewModel>();
          homeVM.refreshTeacher();
          if (homeVM.teacher.value != null) {
            homeVM.teacher.value =
                homeVM.teacher.value!.copyWith(avatar: avatarWithParam);
            homeVM.teacher.notifyListeners();
          }
        }

        if (Get.isRegistered<AccountTeacherViewModel>()) {
          final accountVM = Get.find<AccountTeacherViewModel>();
          accountVM.refreshTeacher();
          if (accountVM.teacher.value != null) {
            accountVM.teacher.value =
                accountVM.teacher.value!.copyWith(avatar: avatarWithParam);
            accountVM.teacher.notifyListeners();
          }
        }
      }
    } catch (e) {
      showToast(title: 'Lỗi khi upload ảnh', type: ToastificationType.error);
    }
  }

  void refreshTeacher() {
    TeacherModel? teacher =
        AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson);
    if (teacher == null) {
      showToast(title: 'Lỗi hệ thống vui lòng thử lại sau');
      Get.offAllNamed(Routers.login);
    }
    AppPrefs.setUser<TeacherModel>(teacher);
    this.teacher.value = teacher!.copyWith(
        avatar: AppUtils.pathMediaToUrlAndRamdomParam(teacher.avatar));
  }

  void refreshUser(String url) async {
    TeacherModel? teacher =
        AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson);
    if (teacher != null) {
      TeacherModel updatedTeacher = teacher.copyWith(avatar: url);
      AppPrefs.setUser(updatedTeacher);
      this.teacher.value = updatedTeacher;
      this.teacher.notifyListeners();
    }
  }
}
