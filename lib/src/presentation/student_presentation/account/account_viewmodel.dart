import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/app_prefs.dart';

class AccountViewModel extends BaseViewModel {
  ValueNotifier<StudentModel?> student = ValueNotifier(null);

  init() async {
    refreshStudent();
  }

  void refreshStudent() {
    student.value = AppPrefs.getUser<StudentModel>(StudentModel.fromJson);
    student.notifyListeners();
  }

  void editProfile() {
    Get.toNamed(Routers.editProfile);
  }

  void changePassword() {
    Get.toNamed(Routers.changePassword);
  }

  void support() {
    Get.toNamed(Routers.support);
  }

  void logout() async {
    NetworkState resultLogout = await authRepository.logout();
    AppPrefs.setUser<StudentModel>(null);
    AppPrefs.password = null;
    AppPrefs.accessToken = null;
    Get.offAllNamed(Routers.chooseRole);
  }

  void refresh() {
    notifyListeners();
  }
}
