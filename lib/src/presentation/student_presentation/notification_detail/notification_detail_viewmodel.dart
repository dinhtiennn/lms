import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';

class NotificationDetailViewModel extends BaseViewModel {
  ValueNotifier<Map<String, dynamic>> notificationData = ValueNotifier({});

  init() async {
    if (Get.arguments != null && Get.arguments is Map) {
      notificationData.value = Get.arguments as Map<String, dynamic>;
      notificationData.notifyListeners();
    } else {}
  }
}
