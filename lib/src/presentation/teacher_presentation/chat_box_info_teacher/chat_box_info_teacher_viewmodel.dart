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

  void toChatBoxMember(ChatBoxModel chatboxParam) async {
    try {
      dynamic result = await Get.toNamed(Routers.chatBoxMemberTeacher,
          arguments: {'chatBox': chatboxParam});
      if (result != null) {
        // Cập nhật lại chatbox với dữ liệu mới
        chatbox.value = result;
        chatbox.notifyListeners();

        // Đảm bảo kết quả được trả về khi quay lại màn hình chi tiết chat
        Get.back(result: chatbox.value);

        logger.i("Đã cập nhật thông tin thành viên nhóm chat");
      }
    } catch (e) {
      logger.e("Lỗi khi cập nhật thông tin thành viên: $e");
    }
  }

  void reNameChatBox(String newName) async {
    try {
      if (chatbox.value?.id == null) {
        showToast(
            title: 'Không thể đổi tên nhóm chat không xác định',
            type: ToastificationType.error);
        return;
      }

      if (newName.isEmpty) {
        showToast(
            title: 'Tên nhóm không được để trống',
            type: ToastificationType.error);
        return;
      }

      // Kiểm tra xem người dùng hiện tại có quyền đổi tên nhóm chat không
      if (chatbox.value?.createdBy != currentUserEmail) {
        showToast(
            title: 'Bạn không có quyền đổi tên nhóm chat này',
            type: ToastificationType.error);
        return;
      }

      // Gọi API đổi tên nhóm chat
      NetworkState resultReName = await chatBoxRepository.reNameChatBox(
          chatBoxId: chatbox.value?.id ?? '', newName: newName);

      if (resultReName.isSuccess) {
        // Cập nhật tên nhóm chat
        chatbox.value = chatbox.value?.copyWith(name: newName);
        chatbox.notifyListeners();

        showToast(
            title: 'Đã đổi tên nhóm chat thành công',
            type: ToastificationType.success);
      } else {
        showToast(
            title: 'Không thể đổi tên nhóm chat. Vui lòng thử lại sau.',
            type: ToastificationType.error);
      }
    } catch (e) {
      logger.e("Lỗi khi đổi tên nhóm chat: $e");
      showToast(
          title: 'Không thể đổi tên nhóm chat. Vui lòng thử lại sau.',
          type: ToastificationType.error);
    }
  }
}
