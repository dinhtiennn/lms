import 'dart:async';
import 'package:get/get.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:toastification/toastification.dart';
import '../../configs/configs.dart';
import '../presentation.dart';

class SplashViewModel extends BaseViewModel {
  init() async {
    logger.d(AppPrefs.onboardScreen);
    AppValues().init();
    firebaseRepository.updateFirebaseToken();

    if (AppPrefs.onboardScreen ?? false) {
      final student = AppPrefs.getUser<StudentModel>(StudentModel.fromJson);
      final teacher = AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson);

      if (student != null) {
        NetworkState<StudentModel> resultStudent = await studentRepository.myInfo();
        if (resultStudent.isSuccess && resultStudent.result != null) {
          AppPrefs.setUser<StudentModel>(resultStudent.result);
          Get.offAllNamed(Routers.navigation);
        }
      } else if (teacher != null) {
        NetworkState<TeacherModel> resultTeacher = await teacherRepository.myInfo();
        if (resultTeacher.isSuccess && resultTeacher.result != null) {
          AppPrefs.setUser<TeacherModel>(resultTeacher.result);
          Get.offAllNamed(Routers.navigationTeacher);
        }
      } else {
        Get.offAllNamed(Routers.chooseRole);
      }
    } else {
      Get.offAllNamed(Routers.welcome);
    }
  }
}
