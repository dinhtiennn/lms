import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:toastification/toastification.dart';

class ResultTestDetailTeacherViewModel extends BaseViewModel {
  ValueNotifier<TestResultView?> result = ValueNotifier(null);
  ValueNotifier<TestModel?> test = ValueNotifier(null);
  ValueNotifier<TestResultModel?> testResult = ValueNotifier(null);

  init() async {
    result.value = Get.arguments['result'];
    test.value = Get.arguments['test'];
    await loadResultTestDetail();
  }

  Future<void> loadResultTestDetail() async {
    NetworkState<TestResultModel> resultTestDetail =
        await groupRepository.testStudentDetailByTeacher(
            testId: test.value?.id, studentId: result.value?.student?.id);
    if (resultTestDetail.isSuccess && resultTestDetail.result != null) {
      testResult.value = resultTestDetail.result;
    } else {
      showToast(
          title: resultTestDetail.message ?? '',
          type: ToastificationType.error);
    }
  }
}
