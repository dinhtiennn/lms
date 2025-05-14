import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:toastification/toastification.dart';

class TestResultViewModel extends BaseViewModel {
  ValueNotifier<TestModel?> test = ValueNotifier(null);
  ValueNotifier<TestResultModel?> testResult = ValueNotifier(null);

  init() async {
    test.value = Get.arguments['test'];
    await loadTestResult();
  }

  Future<void> loadTestResult() async {
    NetworkState<TestResultModel> resultTestDetail = await groupRepository.testStudentDetail(testId: test.value?.id);
    if (resultTestDetail.isSuccess && resultTestDetail.result != null) {
      testResult.value = resultTestDetail.result;
    } else {
      showToast(title: resultTestDetail.message ?? '', type: ToastificationType.error);
    }
  }
}
