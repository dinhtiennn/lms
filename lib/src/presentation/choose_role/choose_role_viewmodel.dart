import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/arguments/argument.dart';
import 'package:toastification/toastification.dart';

class ChooseRoleViewModel extends BaseViewModel {
  String? errMessage;

  init() async {
    final args = Get.arguments;
    if (args != null && args is Map && args['errMessage'] is String) {
      errMessage = args['errMessage'];
    }

    // Chỉ hiển thị toast khi context đã được khởi tạo và có thông báo lỗi
    if ((errMessage?.isNotEmpty ?? false)) {
      showToast(type: ToastificationType.warning, title: errMessage!);
    }
  }

  void selectRole(Role role) {
    // Chuyển đến màn hình đăng nhập tương ứng
    if (role == Role.student) {
      Get.toNamed(Routers.login);
    } else if (role == Role.teacher) {
      Get.toNamed(Routers.loginTeacher);
    }
  }
}
