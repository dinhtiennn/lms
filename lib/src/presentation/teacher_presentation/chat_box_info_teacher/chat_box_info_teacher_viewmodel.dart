import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:toastification/toastification.dart';

class ChatBoxInfoTeacherViewModel extends BaseViewModel {
  ValueNotifier<ChatBoxModel?> chatbox = ValueNotifier(null);
  final ValueNotifier<bool> loading = ValueNotifier(false);

  TeacherModel? teacherModel =
      AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson);
  String? currentUserEmail;
  String? currentUserFullName;

  init() async {
    // Lấy thông tin chat box từ tham số
    chatbox.value = Get.arguments['chatBox'];

    // Lấy thông tin người dùng hiện tại
    currentUserEmail = teacherModel?.email;
    currentUserFullName = teacherModel?.fullName;

    if (chatbox.value == null || currentUserEmail == null) {
      logger.e("Không thể lấy thông tin chatbox hoặc người dùng hiện tại");
      showToast(
          title: "Đã xảy ra lỗi, vui lòng thử lại",
          type: ToastificationType.error);
      return;
    }
  }



  void leaveChatBox() {
    // Xử lý logic rời khỏi chat box
  }
}
