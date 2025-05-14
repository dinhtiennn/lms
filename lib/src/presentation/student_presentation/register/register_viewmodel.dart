import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/arguments/argument.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:toastification/toastification.dart';

class RegisterViewModel extends BaseViewModel {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passWordController = TextEditingController();
  TextEditingController passWordConfirmController = TextEditingController();
  ValueNotifier<MajorModel?> majorSelected = ValueNotifier(null);

  ValueNotifier<List<MajorModel>> majors = ValueNotifier([]);

  init() async {
    _loadMajor();
  }

  void login() {
    Get.offNamed(Routers.login);
  }

  void sendEmail() async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);

    NetworkState resultRegister = await authRepository.sendEmail(email: usernameController.text);
    setLoading(false);
    if (resultRegister.isSuccess && (resultRegister.successCode ?? false)) {
      await showToast(
        title: resultRegister.message ?? 'Verification code sent to email!',
        type: ToastificationType.success,
      );
      Get.toNamed(Routers.otp,
          arguments: OtpArgument(
              otpType: OtpType.register,
              role: Role.student,
              email: usernameController.text,
              password: passWordController.text,
              fullname: fullNameController.text,
              major: majorSelected.value?.id));
    } else {
      showToast(
        title: resultRegister.message ?? 'Verification code sent to email!',
        type: ToastificationType.error,
      );
    }
  }

  void _loadMajor() async {
    NetworkState<List<MajorModel>> resultMajor = await majorRepository.getAllMajor();
    setLoading(false);
    if (resultMajor.isSuccess && resultMajor.result != null) {
      majorSelected.value = (resultMajor.result ?? []).first;
      majors.value = resultMajor.result ?? [];
      majors.notifyListeners();
    }
  }

  void setMajor(MajorModel? newValue) {
    majorSelected.value = newValue;
    majorSelected.notifyListeners();
  }
}
