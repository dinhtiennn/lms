import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:local_auth/local_auth.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/utils/utils.dart';
import 'package:toastification/toastification.dart';

class LoginTeacherViewModel extends BaseViewModel {
  final formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final passWordController = TextEditingController();
  final preferredBiometric = ValueNotifier<BiometricType?>(null);
  bool authSuccess = false;
  LocalAuthentication? localAuth;
  String? errMessage;

  init() async {
    localAuth = LocalAuthentication();
    await checkBiometricSupport();
    errMessage = Get.arguments?['errMessage'] ?? '';
    if (errMessage != null && errMessage!.isNotEmpty) {
      showToast(type: ToastificationType.warning, title: errMessage!);
    }
  }

  Future<void> checkBiometricSupport() async {
    bool canCheck = await localAuth!.canCheckBiometrics;
    if (localAuth == null) {
      return;
    }
    List<BiometricType> availableBiometrics = await localAuth!.getAvailableBiometrics();
    if (canCheck) {
      if (availableBiometrics.contains(BiometricType.strong)) {
        preferredBiometric.value = BiometricType.strong;
      } else if (availableBiometrics.contains(BiometricType.face)) {
        preferredBiometric.value = BiometricType.face;
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        preferredBiometric.value = BiometricType.fingerprint;
      } else {
        preferredBiometric.value = null;
      }
      preferredBiometric.notifyListeners();
    }
  }

  void auth() async {
    // Lấy thông tin giảng viên từ AppPrefs
    TeacherModel? teacher = AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson);

    // Nếu không có teacher thì thông báo cho người dùng
    if (teacher == null) {
      await showToast(
        title: 'please_complete_your_first_login'.tr,
        type: ToastificationType.error,
      );
      return;
    }

    // Nếu đã có teacher và localAuth không null
    if (localAuth != null) {
      try {
        // Thực hiện xác thực sinh trắc học
        final authSuccess = await localAuth!.authenticate(localizedReason: "Vui lòng xác thực để tiếp tục.");

        // Nếu xác thực thành công, gọi hàm login
        if (authSuccess) {
          login(passwordAuthLocal: AppPrefs.password, usernameAuthLocal: teacher.email);
        } else {
          await showToast(
            title: 'authentication_failed'.tr,
            type: ToastificationType.error,
          );
        }
      } catch (e) {
        toast('Có lỗi xảy ra trong quá trình xác thực: ${e.toString()}');
      }
    } else {
      await showToast(
        title: 'this_device_does_not_support_biometric_authentication'.tr,
        type: ToastificationType.warning,
      );
    }
  }

  void login({String? usernameAuthLocal, String? passwordAuthLocal}) async {
    if (usernameAuthLocal != null && passwordAuthLocal != null) {
      userNameController.text = usernameAuthLocal;
      passWordController.text = passwordAuthLocal;
    }
    String username = usernameAuthLocal ?? userNameController.text;
    String password = passwordAuthLocal ?? passWordController.text;

    if (!formKey.currentState!.validate()) return;

    bool checked = false;
    setLoading(true);

    NetworkState<String> resultToken = await authRepository.getToken(username: username, password: password);
    setLoading(false);

    if (resultToken.isSuccess && resultToken.result != null) {
      AppPrefs.accessToken = resultToken.result;
      AppPrefs.refreshToken = resultToken.result;
      NetworkState<TeacherModel> resultProfile = await teacherRepository.myInfo();

      if (resultProfile.isSuccess && resultProfile.result != null) {
        AppPrefs.setUser<TeacherModel>(resultProfile.result);
        AppPrefs.password = password;
        checked = true;
      } else {
        await showToast(
          title: resultProfile.message ?? 'unknown_error'.tr,
          type: ToastificationType.error,
        );
      }
    } else {
      await showToast(
        title: resultToken.message ?? 'unknown_error'.tr,
        type: ToastificationType.error,
      );
    }
    if (checked && context.mounted) {
      await StompService.instance();
      if(context.mounted){
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routers.navigationTeacher,
              (route) => false,
        );
      }
    }
  }

  void forgotPassword() {
    Get.toNamed(Routers.forgotPassword);
  }

  void loginWithGoogle() {}

  void register() {
    Get.toNamed(Routers.registerTeacher);
  }
}
