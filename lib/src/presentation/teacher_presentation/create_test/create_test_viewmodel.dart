import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:toastification/toastification.dart';

class CreateTestViewModel extends BaseViewModel {
  ValueNotifier<GroupModel?> group = ValueNotifier(null);
  final formKey = GlobalKey<FormState>();
  TextEditingController titleTest = TextEditingController();
  TextEditingController descriptionTest = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController expiredAtDateController = TextEditingController();
  TextEditingController expiredAtTimeController = TextEditingController();

  init() async {
    group.value = Get.arguments['group'];
  }

  void createTest(BuildContext context, List<TestQuestionRequestModel> questions) async {
    final fullDateStartTimeString = '${startDateController.text} ${startTimeController.text}';
    final fullDateEndTimeString = '${expiredAtDateController.text} ${expiredAtTimeController.text}';

    final format = DateFormat('dd/MM/yyyy HH:mm');

    NetworkState resultCreateTestRequest = await groupRepository.createTestRequest(
        groupId: group.value?.id,
        title: titleTest.text,
        description: descriptionTest.text,
        startedAt: format.parse(fullDateStartTimeString),
        expiredAt: format.parse(fullDateEndTimeString),
        questions: questions);

    if (resultCreateTestRequest.isSuccess) {
      if (Get.isRegistered<GroupDetailTeacherViewModel>()) {
        Get.find<GroupDetailTeacherViewModel>().refreshTest();
      }
      showToast(title: 'Tạo bài kiểm tra thành công', type: ToastificationType.success);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      showToast(title: resultCreateTestRequest.message ?? 'Lỗi không xác định', type: ToastificationType.error);
    }
  }
}
