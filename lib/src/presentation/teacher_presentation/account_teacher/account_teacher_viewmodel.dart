import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:lms/src/utils/app_utils.dart';

class AccountTeacherViewModel extends BaseViewModel {
  ValueNotifier<TeacherModel?> teacher = ValueNotifier(null);

  init() async {
    refreshTeacher();
  }

  void editProfile() {
    Get.toNamed(Routers.editProfileTeacher);
  }

  void changePassword() {
    Get.toNamed(Routers.changePasswordTeacher);
  }

  void support() {
    Get.toNamed(Routers.support);
  }

  void logout() async {
    NetworkState resultLogout = await authRepository.logout();
    AppPrefs.setUser<TeacherModel>(null);
    AppPrefs.password = null;
    AppPrefs.accessToken = null;
    Get.offAllNamed(Routers.chooseRole);
  }

  void getUser() {
    teacher.value = AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson);
  }

  void refreshTeacher() {
    TeacherModel? teacher = AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson);
    if (teacher == null) {
      showToast(title: 'Lỗi hệ thống vui lòng thử lại sau');
      Get.offAllNamed(Routers.login);
    }
    AppPrefs.setUser<TeacherModel>(teacher);
    this.teacher.value = teacher!.copyWith(avatar: AppUtils.pathMediaToUrlAndRamdomParam(teacher.avatar));
  }

  void refresh() {
    notifyListeners();
  }
}
