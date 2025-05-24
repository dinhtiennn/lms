import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:local_auth/local_auth.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:toastification/toastification.dart';

class LoginViewModel extends BaseViewModel {
  bool authSuccess = false;
  LocalAuthentication? localAuth;
  final formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final passWordController = TextEditingController();
  final preferredBiometric = ValueNotifier<BiometricType?>(null);

  init() async {
    localAuth = LocalAuthentication();
    await checkBiometricSupport();
  }

  Future<void> checkBiometricSupport() async {
    bool canCheck = await localAuth!.canCheckBiometrics;
    if (localAuth == null) {
      return;
    }
    List<BiometricType> availableBiometrics =
        await localAuth!.getAvailableBiometrics();
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
    // Lấy thông tin sinh viên từ AppPrefs
    StudentModel? student =
        AppPrefs.getUser<StudentModel>(StudentModel.fromJson);

    // Nếu không có student thì thông báo cho người dùng
    if (student == null) {
      await showToast(
        title: 'please_complete_your_first_login'.tr,
        type: ToastificationType.error,
      );
      return;
    }

    // Nếu đã có student và localAuth không null
    if (localAuth != null) {
      try {
        // Thực hiện xác thực sinh trắc học
        final authSuccess = await localAuth!
            .authenticate(localizedReason: "Vui lòng xác thực để tiếp tục.");

        // Nếu xác thực thành công, gọi hàm login
        if (authSuccess) {
          login(
              passwordAuthLocal: AppPrefs.password,
              usernameAuthLocal: student.email);
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

    NetworkState<String> resultToken =
        await authRepository.getToken(username: username, password: password, role: 'STUDENT');
    setLoading(false);

    if (resultToken.isSuccess && resultToken.result != null) {
      AppPrefs.accessToken = resultToken.result;
      AppPrefs.refreshToken = resultToken.result;
      NetworkState<StudentModel> resultProfile =
          await studentRepository.myInfo();

      if (resultProfile.isSuccess && resultProfile.result != null) {
        AppPrefs.setUser<TeacherModel>(null);
        AppPrefs.setUser<StudentModel>(resultProfile.result);
        AppPrefs.password = password;
        checked = true;
      } else {
        await showToast(
          title: 'Sai thông tin đăng nhập',
          type: ToastificationType.error,
        );
      }
    } else {
      await showToast(
        title: 'Sai thông tin đăng nhập',
        type: ToastificationType.error,
      );
    }
    if (checked && context.mounted) {
      // Khởi tạo StompService
      await StompService.instance();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routers.navigation,
          (route) => false,
        );
      }
    }
  }

  // Future<void> loginWithGoogle() async {
  //   NetworkState<StudentModel> result = await authRepository.loginGoogle();
    // if (result.isSuccess && (result.statusData ?? false)) {
    //   StudentModel student = result.result!;
    //   AppPrefs.accessToken = authModel.token;
    //   AppPrefs.user = authModel.userModel;
    //   if (Get.isRegistered<NavigationViewModel>()) {
    //     Get.isRegistered<HomeViewModel>()
    //         ? Get.find<HomeViewModel>().getAuth()
    //         : null;
    //     Get.until((route) => Get.currentRoute == Routers.navigation);
    //   } else {
    //     Get.toNamed(Routers.navigation);
    //   }
    // }else{
    //   if (context.mounted) {
    //     WidgetToast.showToast(
    //         context: context,
    //         message: result.message!,
    //         status: result.statusData!);
    //   }
    // }
  // }

  void forgotPassword() {
    Get.toNamed(Routers.forgotPassword);
  }

  void register() {
    Get.offNamed(Routers.register);
  }
}
