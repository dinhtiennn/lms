import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:lms/src/resource/websocket_stomp/websocket_stomp.dart';
import 'package:lms/src/resource/resource.dart';

class AccountViewModel extends BaseViewModel {
  ValueNotifier<StudentModel?> student = ValueNotifier(null);
  final AuthRepository authRepository = AuthRepository();

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

  void allRequest() {
    Get.toNamed(Routers.allRequestJoinCourseByStudent);
  }

  void logout() async {
    try {
      final StompService? stompService = await StompService.instance();
      if (stompService != null) {
        logger.i("Ngắt kết nối socket...");
        stompService.disconnect();
      }

      NetworkState resultLogout = await authRepository.logout();
      AppPrefs.setUser<StudentModel>(null);
      AppPrefs.password = null;
      AppPrefs.accessToken = null;

      Get.offAllNamed(Routers.chooseRole);
    } catch (e) {
      logger.e("Lỗi khi đăng xuất: $e");
      // Đảm bảo rằng người dùng vẫn có thể đăng xuất ngay cả khi có lỗi
      AppPrefs.setUser<StudentModel>(null);
      AppPrefs.password = null;
      AppPrefs.accessToken = null;
      Get.offAllNamed(Routers.chooseRole);
    }
  }

  void refresh() {
    notifyListeners();
  }
}
