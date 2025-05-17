import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/utils/app_prefs.dart';

class WelcomeViewModel extends BaseViewModel {
  ValueNotifier<int> screenIndex = ValueNotifier(0);
  final int totalScreens = 4;

  init() async {}

  void onContinue() {
    if (screenIndex.value < totalScreens - 1) {
      // Move to next screen
      screenIndex.value++;
    } else {
      AppPrefs.onboardScreen = true;
      Get.offAllNamed(Routers.chooseRole);
    }
  }

  void skipOnboarding() {
    Get.offAllNamed(Routers.chooseRole);
  }

  void previous() {
    screenIndex.value = screenIndex.value - 1;
    screenIndex.notifyListeners();
  }

  void chooseRole(){
    AppPrefs.onboardScreen = true;
    Get.toNamed(Routers.chooseRole);
  }
}
