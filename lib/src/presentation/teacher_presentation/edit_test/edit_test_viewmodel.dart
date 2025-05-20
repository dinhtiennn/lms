import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:toastification/toastification.dart';

class EditTestViewModel extends BaseViewModel {
  ValueNotifier<TestModel?> test = ValueNotifier(null);
  final formKey = GlobalKey<FormState>();
  TextEditingController titleTest = TextEditingController();
  TextEditingController descriptionTest = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController expiredAtDateController = TextEditingController();
  TextEditingController expiredAtTimeController = TextEditingController();

  ValueNotifier<List<TestQuestionRequestModel>> questions = ValueNotifier([]);
  ValueNotifier<bool> isUpdating = ValueNotifier(false);

  init() async {
    test.value = Get.arguments['test'];

    // Nạp dữ liệu từ test vào các controller
    if (test.value != null) {
      titleTest.text = test.value?.title ?? '';
      descriptionTest.text = test.value?.description ?? '';

      // Format các trường ngày giờ
      if (test.value?.startedAt != null) {
        startDateController.text = DateFormat('dd/MM/yyyy').format(test.value!.startedAt!);
        startTimeController.text = DateFormat('HH:mm').format(test.value!.startedAt!);
      }

      if (test.value?.expiredAt != null) {
        expiredAtDateController.text = DateFormat('dd/MM/yyyy').format(test.value!.expiredAt!);
        expiredAtTimeController.text = DateFormat('HH:mm').format(test.value!.expiredAt!);
      }

      // Tải danh sách câu hỏi của bài kiểm tra
      loadTestQuestions();
    }
  }

  Future<void> loadTestQuestions() async {
    if (test.value?.id == null) return;

    setLoading(true);
    NetworkState<TestDetailModel> result = await groupRepository.testDetail(testId: test.value?.id);
    setLoading(false);

    if (result.isSuccess && result.result != null) {
      final testDetail = result.result!;
      questions.value = testDetail.questions
              ?.map((q) => TestQuestionRequestModel(
                  id: q.id,
                  content: q.content,
                  point: q.point,
                  type: q.type,
                  options: q.options,
                  correctAnswers: q.correctAnswers))
              .toList() ??
          [];
    } else {
      questions.value = [];
      showToast(title: 'Không thể tải câu hỏi', type: ToastificationType.error);
    }
  }

  Map<String, dynamic> getTestUpdateInfo() {
    try {
      final fullDateStartTimeString = '${startDateController.text} ${startTimeController.text}';
      final fullDateEndTimeString = '${expiredAtDateController.text} ${expiredAtTimeController.text}';
      final format = DateFormat('dd/MM/yyyy HH:mm');

      return {
        'testId': test.value?.id ?? '',
        'title': titleTest.text,
        'description': descriptionTest.text,
        'startedAt': format.parse(fullDateStartTimeString),
        'expiredAt': format.parse(fullDateEndTimeString),
        'totalQuestions': questions.value.length,
        'questions': questions.value,
      };
    } catch (e) {
      showToast(title: 'Lỗi định dạng ngày tháng: $e', type: ToastificationType.error);
      return {};
    }
  }

  String getQuestionsPreview() {
    String result = '';
    for (int i = 0; i < questions.value.length; i++) {
      final question = questions.value[i];
      result += 'Câu ${i + 1}: ${question.content}\n';
      result += '   Điểm: ${question.point}\n';
      result += '   Loại: ${getQuestionTypeText(question.type ?? '')}\n';

      if (question.type != 'text') {
        result += '   Đáp án đúng: ${question.correctAnswers}\n';
        if (question.options != null && question.options!.isNotEmpty) {
          result += '   Các lựa chọn:\n';
          final options = question.options!.split(';');
          for (var option in options) {
            result += '      $option\n';
          }
        }
      }
      result += '\n';
    }
    return result;
  }

  String getQuestionTypeText(String type) {
    switch (type) {
      case 'SINGLE_CHOICE':
        return 'Chọn một đáp án';
      case 'MULTIPLE_CHOICE':
        return 'Chọn nhiều đáp án';
      case 'text':
        return 'Tự luận';
      default:
        return type;
    }
  }

  Future<void> updateTest(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    try {
      isUpdating.value = true;
      final testInfo = getTestUpdateInfo();

      // Kiểm tra thời gian hiện tại so với thời gian bắt đầu ban đầu của bài kiểm tra
      if (test.value?.startedAt != null) {
        final DateTime now = DateTime.now();
        final DateTime originalStartTime = test.value!.startedAt!;

        if (now.isAfter(originalStartTime)) {
          isUpdating.value = false;
          showToast(title: 'Đã hết thời hạn cập nhật bài kiểm tra', type: ToastificationType.error);
          return;
        }
      }

      NetworkState<TestModel> resultUpdateTest = await groupRepository.updateTest(
        testId: testInfo['testId'],
        title: testInfo['title'],
        description: testInfo['description'],
        startedAt: testInfo['startedAt'],
        expiredAt: testInfo['expiredAt'],
        questions: questions.value,
      );

      // Xử lý kết quả
      if (resultUpdateTest.isSuccess) {
        showToast(title: 'Cập nhật bài kiểm tra thành công', type: ToastificationType.success);
        loadTestQuestions();
        if (context.mounted) {
          Navigator.pop(context);
        }
        if (Get.isRegistered<GroupDetailTeacherViewModel>()) {
          Get.find<GroupDetailTeacherViewModel>().refreshTest();
        }
      } else {
        showToast(
            title: 'Lỗi: ${resultUpdateTest.message ?? "Không thể cập nhật bài kiểm tra"}',
            type: ToastificationType.error);
      }

      isUpdating.value = false;
    } catch (e) {
      isUpdating.value = false;
      showToast(title: 'Đã xảy ra lỗi: $e', type: ToastificationType.error);
    }
  }

  void addQuestion(TestQuestionRequestModel question) {
    List<TestQuestionRequestModel> newQuestions = List.from(questions.value);
    newQuestions.add(question);
    questions.value = newQuestions;
  }

  void updateQuestion(int index, TestQuestionRequestModel question) {
    List<TestQuestionRequestModel> newQuestions = List.from(questions.value);
    newQuestions[index] = question;
    questions.value = newQuestions;
  }

  void removeQuestion(int index) {
    List<TestQuestionRequestModel> newQuestions = List.from(questions.value);
    newQuestions.removeAt(index);
    questions.value = newQuestions;
  }
}
