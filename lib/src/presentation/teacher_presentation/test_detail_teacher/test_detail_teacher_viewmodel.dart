import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:toastification/toastification.dart';

class TestDetailTeacherViewModel extends BaseViewModel {
  ValueNotifier<TestModel?> test = ValueNotifier(null);
  ValueNotifier<TestDetailModel?> testDetail = ValueNotifier(null);
  ValueNotifier<List<TestResultView>?> testResults = ValueNotifier(null);
  ValueNotifier<bool> isLoadingMore = ValueNotifier(false);
  final ScrollController scrollController = ScrollController();
  int currentPage = 0;
  bool hasMoreData = true;
  int pageSize = 10;


  init() async {
    test.value = Get.arguments['test'];
    scrollController.addListener(_onScroll);
    await loadTestDetail();
    await loadTestResultView();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  Future<void> loadTestDetail() async {
    NetworkState<TestDetailModel> resultTestDetail =
        await groupRepository.testDetail(testId: test.value?.id);
    if (resultTestDetail.isSuccess && resultTestDetail.result != null) {
      testDetail.value = resultTestDetail.result;
    } else {
      showToast(
          title: resultTestDetail.message ?? '',
          type: ToastificationType.error);
    }
  }

  Future<void> loadTestResultView({int pageNumber = 0}) async {
    if (isLoadingMore.value) return;

    if (pageNumber == 0) {
      setLoading(true);
    } else {
      isLoadingMore.value = true;
      isLoadingMore.notifyListeners();
    }

    NetworkState<List<TestResultView>> testResultViewTestDetail =
        await groupRepository.testResultView(testId: test.value?.id, pageSize: pageSize, pageNumber: pageNumber);
    if (testResultViewTestDetail.isSuccess && testResultViewTestDetail.result != null) {
      if (pageNumber == 0) {
        testResults.value = testResultViewTestDetail.result;
      } else {
        List<TestResultView> currentRequests =
        List.from(testResults.value ?? []);
        currentRequests.addAll(testResultViewTestDetail.result!);
        testResults.value = currentRequests;
      }
      hasMoreData = testResultViewTestDetail.result!.length >= pageSize;
      currentPage = pageNumber;
    }

    if (pageNumber == 0) {
      setLoading(false);
    } else {
      isLoadingMore.value = false;
      isLoadingMore.notifyListeners();
    }
  }

  void loadMore() {
    if (!isLoadingMore.value && hasMoreData) {
      loadTestResultView(pageNumber: currentPage + 1);
    }
  }

  void resultTestDetail(TestResultView result) {
    Get.toNamed(Routers.resultTestDetailTeacher, arguments: {'result' : result, 'test': test.value});
  }
}
