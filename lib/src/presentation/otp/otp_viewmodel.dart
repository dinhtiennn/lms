import 'package:lms/src/presentation/presentation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/resource/arguments/argument.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:toastification/toastification.dart';

class OtpViewModel extends BaseViewModel {
  OtpArgument? otpArgument;
  TextEditingController pinCodeController = TextEditingController();
  ValueNotifier<String> phoneNumber = ValueNotifier('');

  //
  init() async {
    otpArgument =  Get.arguments;
    //   phoneNumber.value = otpArgument.name.split('').asMap().entries.map((entry) {
    //     int index = entry.key;
    //     String char = entry.value;
    //     if (index < 3 || index >= otpArgument.name.length - 2) {
    //       return char;
    //     } else {
    //       return '*';
    //     }
    //   }).join();
    //   phoneNumber.notifyListeners();
  }

  //
  Future<void> verifyOtp() async {
    if (otpArgument == null) {
      return;
    }

    _handleRegistrationOtp(otpArgument!);

    // switch (otpArgument!.otpType) {
    //   case OtpType.register:
    //     _handleRegistrationOtp(otpArgument!);
    //     print("Đăng ký tài khoản");
    //     break;
    // case OtpType.changePassword:
    // // Xử lý logic cho Quên mật khẩu
    //   print("Quên mật khẩu");
    //   break;
    // case OtpType.updatePassword:
    // // Xử lý logic cho Đổi mật khẩu
    //   print("Đổi mật khẩu");
    //   break;
    // }
  }

//
  void resendOtp() async {
    if (otpArgument?.email == null) {
      showToast(title: 'Lỗi hệ thống, vui lòng quay lại trang đăng ký');
      return;
    }

    setLoading(true);

    NetworkState resultRegister = await authRepository.sendEmail(email: otpArgument!.email!);
    setLoading(false);
    if (resultRegister.isSuccess && resultRegister.result != null) {
      await showToast(
        title: resultRegister.message ?? 'Verification code sent to email!',
        type: ToastificationType.success,
      );
    }
  }

  Future<void> _handleRegistrationOtp(OtpArgument otpArgument) async {
    if (otpArgument.role == Role.student) {
      if (otpArgument.email == null ||
          otpArgument.fullname == null ||
          otpArgument.password == null ||
          otpArgument.major == null) {
        showToast(title: 'Lỗi hệ thống, vui lòng quay lại trang đăng ký');
        return;
      }
      setLoading(true);
      NetworkState resultVerify =
          await authRepository.verifyOtp(email: otpArgument.email!, otp: pinCodeController.text);
      setLoading(false);
      if (resultVerify.isSuccess && (resultVerify.successCode ?? false)) {
        NetworkState resultRegister = await authRepository.registerStudent(
            username: otpArgument.email!,
            password: otpArgument.password!,
            fullname: otpArgument.fullname!,
            majorId: otpArgument.major!);
        if (resultRegister.isSuccess && (resultRegister.successCode ?? false)) {
          showToast(
            title: 'Register success!',
            type: (resultRegister.successCode ?? false) ? ToastificationType.success : ToastificationType.error,
          );
          await Future.delayed(
            const Duration(seconds: 2),
            () => Get.back(),
          );
          Get.offNamed(Routers.login);
        } else {
          showToast(
            title: resultRegister.message ?? 'Error',
            type: (resultRegister.successCode ?? false) ? ToastificationType.success : ToastificationType.error,
          );
        }
      } else {
        showToast(
          title: resultVerify.message ?? '',
          type: (resultVerify.successCode ?? false) ? ToastificationType.success : ToastificationType.error,
        );
      }
    } else if (otpArgument.role == Role.teacher) {
      if (otpArgument.email == null ||
          otpArgument.fullname == null ||
          otpArgument.password == null) {
        showToast(title: 'Lỗi hệ thống, vui lòng quay lại trang đăng ký');
        return;
      }
      setLoading(true);
      NetworkState resultVerify =
          await authRepository.verifyOtp(email: otpArgument.email!, otp: pinCodeController.text);
      setLoading(false);
      if (resultVerify.isSuccess && (resultVerify.successCode ?? false)) {
        NetworkState resultRegister = await authRepository.registerTeacher(
          username: otpArgument.email!,
          password: otpArgument.password!,
          fullname: otpArgument.fullname!,
        );
        if (resultRegister.isSuccess && (resultRegister.successCode ?? false)) {
          showToast(
            title: 'Register success!',
            type: (resultRegister.successCode ?? false) ? ToastificationType.success : ToastificationType.error,
          );
          await Future.delayed(
            const Duration(seconds: 2),
            () => Get.back(),
          );
          Get.offNamed(Routers.login);
        } else {
          showToast(
            title: resultRegister.message ?? 'Error',
            type: (resultRegister.successCode ?? false) ? ToastificationType.success : ToastificationType.error,
          );
        }
      } else {
        showToast(
          title: resultVerify.message ?? '',
          type: (resultVerify.successCode ?? false) ? ToastificationType.success : ToastificationType.error,
        );
      }
    }
  }
//
// Future<void> _handleForgotPasswordOtp(OtpArgument otpArgument) async {
//   Get.dialog(
//     WidgetDialogSuccess(
//       message: 'OTP for registration: ${otpArgument.name}',
//       success: true,
//     ),
//     barrierDismissible: false,
//   );
//
//   Future.delayed(
//     const Duration(seconds: 2),
//     () => Get.back(),
//   );
// }
}
