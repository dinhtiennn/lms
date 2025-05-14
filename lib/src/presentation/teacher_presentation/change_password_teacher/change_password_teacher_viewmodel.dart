import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/utils.dart';
import 'package:toastification/toastification.dart';

class ChangePasswordTeacherViewModel extends BaseViewModel {
  final formKey = GlobalKey<FormState>();
  OtpArgument? otpArgument;
  final TextEditingController oldPassword = TextEditingController();
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController newPasswordConfirm = TextEditingController();

  void init() {
    otpArgument = Get.arguments as OtpArgument?;
  }

  Future<void> savePassword() async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);

    NetworkState resultChangerPassword =
        await studentRepository.changerPassword(oldPass: oldPassword.text, newPass: newPasswordConfirm.text);
    setLoading(false);
    if (resultChangerPassword.isSuccess) {
      logger.e(resultChangerPassword);
      AppPrefs.password = newPasswordConfirm.text;
      await showToast(
        title: 'password_changed_successfully'.tr,
        type: ToastificationType.success,
      );
      //điều hướng về màn hình login từ luồng quên mật khẩu
      if (otpArgument != null && context.mounted) {
        String backRouter = Routers.login;
        Navigator.of(context).popUntil(ModalRoute.withName(backRouter));
      } else {
        //điều hướng về màn hình account từ luồng update password
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    } else {
      await showToast(
        title: resultChangerPassword.message ?? '',
        type: ToastificationType.error,
      );
    }
  }
}
