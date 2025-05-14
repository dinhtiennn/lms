import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/utils.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:toastification/toastification.dart';

class ProfileViewModel extends BaseViewModel {
  ValueNotifier<StudentModel?> studentModel = ValueNotifier(null);
  final ImagePicker picker = ImagePicker();
  XFile? avatar;

  init() async {
    refreshStudent();
  }

  void refreshStudent() {
    StudentModel? student = AppPrefs.getUser<StudentModel>(StudentModel.fromJson);
    if(student == null){
      showToast(title: 'Lỗi hệ thống vui lòng thử lại sau');
      Get.offAllNamed(Routers.login);
    }
    AppPrefs.setUser<StudentModel>(student);
    studentModel.value = student!.copyWith(avatar: AppUtils.pathMediaToUrlAndRamdomParam(student.avatar));
    studentModel.notifyListeners();
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
      final String? studentId = studentModel.value?.id;

      if (!saveConfirmed) return;
      if (studentId == null || studentId.isEmpty) {
        toast('lỗi không xác định user');
        return;
      }
      setLoading(true);
      NetworkState resultUpdateAvatar = await studentRepository.updateAvatar(
        id: studentId,
        avatar: pickedImageFile,
      );
      setLoading(false);
      if (resultUpdateAvatar.isSuccess) {
        refreshUser(resultUpdateAvatar.result);
        showToast(
          title: 'successfully_changed_avatar'.tr,
          type: ToastificationType.success,
        );
        refreshStudent();
        if (Get.isRegistered<HomeViewModel>()) {
          Get.find<HomeViewModel>().refreshStudent();
        }
        if (Get.isRegistered<AccountViewModel>()) {
          Get.find<AccountViewModel>().refreshStudent();
        }
      }
    } catch (e) {
      toast('Lỗi khi upload ảnh');
    }
  }

  void refreshUser(String url) async {
    StudentModel? student = AppPrefs.getUser<StudentModel>(StudentModel.fromJson);
    AppPrefs.setUser(student!.copyWith(avatar: url));
  }
}
