import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:toastification/toastification.dart';

class TestDetailViewModel extends BaseViewModel {
  ValueNotifier<TestModel?> test = ValueNotifier(null);
  ValueNotifier<TestDetailModel?> testDetail = ValueNotifier(null);

  ValueNotifier<List<AnswerModel>?> selectedAnswers = ValueNotifier([]);
  ValueNotifier<bool> violationDetected = ValueNotifier(false);

  Timer? _expirationTimer;
  bool _notificationShown = false;
  bool _autoSubmitTriggered = false;
  StreamSubscription<FGBGType>? _subscription;
  DateTime? _lastBackgroundedTime;

  // Số lần vi phạm
  int _violationCount = 0;
  // Thời gian tối đa cho phép ở chế độ nền (tính bằng giây)
  final int _maxBackgroundTimeInSeconds = 2;

  @override
  void dispose() {
    _subscription?.cancel();
    _expirationTimer?.cancel();
    super.dispose();
  }

  init() async {
    test.value = Get.arguments['test'];

    // Bắt đầu theo dõi trạng thái ứng dụng
    _subscription = FGBGEvents.instance.stream.listen((event) {
      if (event == FGBGType.background) {
        _onAppBackground();
      } else if (event == FGBGType.foreground) {
        _onAppForeground();
      }
    });

    await loadTestDetail();
    _startExpirationTimer();
  }

  void _onAppBackground() {
    _lastBackgroundedTime = DateTime.now();
    logger.i("App ở background tại: $_lastBackgroundedTime");
  }

  void _onAppForeground() {
    if (_lastBackgroundedTime != null && !violationDetected.value) {
      final now = DateTime.now();
      final timeInBackground = now.difference(_lastBackgroundedTime!).inSeconds;

      logger.i(
          "Quay lại sau $timeInBackground giây dưới nền");

      if (timeInBackground > _maxBackgroundTimeInSeconds) {
        _violationCount++;

        logger.w(
            "Đã phát hiện vi phạm: Ứng dụng ở chế độ nền cho $timeInBackground giây");

        if (_violationCount >= 2) {
          // Sau 2 lần vi phạm, đánh dấu là vi phạm nghiêm trọng
          violationDetected.value = true;
        } else {
          // Cảnh báo người dùng
          showToast(
            title: 'Cảnh báo vi phạm quy định kiểm tra!',
            type: ToastificationType.warning,
          );
        }
      }
    }
    _lastBackgroundedTime = null;
  }

  void _startExpirationTimer() {
    _expirationTimer?.cancel();

    if (testDetail.value?.expiredAt != null) {
      _expirationTimer = Timer.periodic(Duration(seconds: 10), (timer) {
        _checkExpirationTime();
      });
    }
  }

  void _checkExpirationTime() {
    final expiredAt = testDetail.value?.expiredAt;
    if (expiredAt == null) return;

    final now = DateTime.now();
    final difference = expiredAt.difference(now);

    if (difference.inSeconds > 0 &&
        difference.inSeconds <= 60 &&
        !_notificationShown) {
      _notificationShown = true;
      showToast(
        title: 'Sắp hết thời gian kiểm tra! Còn dưới 1 phút.',
        type: ToastificationType.warning,
      );
    }

    if (difference.inSeconds <= 0 && !_autoSubmitTriggered) {
      _autoSubmitTriggered = true;
      _expirationTimer?.cancel();

      if (test.value?.isSuccess != true) {
        showToast(
          title: 'Đã hết thời gian làm bài! Hệ thống sẽ tự động nộp bài.',
          type: ToastificationType.info,
        );

        Future.delayed(Duration(seconds: 2), () {
          autoSubmitTest();
        });
      }
    }
  }

  void autoSubmitTest() async {
    NetworkState resultSubmit = await groupRepository.submitTest(
        testId: test.value?.id, answers: selectedAnswers.value);
    if (resultSubmit.isSuccess) {
      showToast(
          title: 'Bài kiểm tra đã được nộp tự động',
          type: ToastificationType.success);
      if (Get.isRegistered<GroupDetailViewModel>()) {
        Get.find<GroupDetailViewModel>().refreshTest();
      }
      Get.back();
    } else {
      showToast(
          title: resultSubmit.message ?? 'Lỗi khi nộp bài tự động',
          type: ToastificationType.error);
    }
  }

  Future<void> loadTestDetail() async {
    NetworkState<TestDetailModel> resultTestDetail =
        await groupRepository.testDetail(testId: test.value?.id);
    if (resultTestDetail.isSuccess && resultTestDetail.result != null) {
      testDetail.value = resultTestDetail.result;
      _startExpirationTimer();
    } else {
      showToast(
          title: resultTestDetail.message ?? '',
          type: ToastificationType.error);
    }
  }

  void submitTest(BuildContext context) async {
    NetworkState resultSubmit = await groupRepository.submitTest(
        testId: test.value?.id, answers: selectedAnswers.value);
    if (resultSubmit.isSuccess) {
      showToast(title: 'Nộp bài thành công', type: ToastificationType.success);
      if (Get.isRegistered<GroupDetailViewModel>()) {
        Get.find<GroupDetailViewModel>().refreshTest();
      }
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      showToast(
          title: resultSubmit.message ?? '', type: ToastificationType.error);
    }
  }

  void addAnswer(AnswerModel answer) {
    List<AnswerModel> currentAnswers = selectedAnswers.value ?? [];
    int existingIndex =
        currentAnswers.indexWhere((a) => a.questionId == answer.questionId);

    if (existingIndex != -1) {
      currentAnswers[existingIndex] = answer;
    } else {
      currentAnswers.add(answer);
    }

    selectedAnswers.value = List.from(currentAnswers);
  }

  void updateAnswer(String questionId, String newAnswer) {
    if (selectedAnswers.value == null) return;

    List<AnswerModel> updatedAnswers = List.from(selectedAnswers.value!);
    final index = updatedAnswers.indexWhere((a) => a.questionId == questionId);

    if (index != -1) {
      AnswerModel oldAnswer = updatedAnswers[index];
      updatedAnswers[index] = AnswerModel(
        questionId: oldAnswer.questionId,
        answer: newAnswer,
      );
      selectedAnswers.value = updatedAnswers;
    }
  }
}
