import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:toastification/toastification.dart';

class ForgotPasswordViewModel extends BaseViewModel {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  init() async {}

  void verify() async {
    if (!formKey.currentState!.validate()) return;
    setLoading(true);
    NetworkState resultChangePass = await authRepository.changePass(email: emailController.text);
    setLoading(false);
    if (resultChangePass.isSuccess) {
      showToast(title: 'Mật khẩu mới đã được gửi đến Email', type: ToastificationType.success);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      showToast(title: resultChangePass.message ?? '', type: ToastificationType.error);
    }
  }
}
