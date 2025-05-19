import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:toastification/toastification.dart';

class GroupDetailViewModel extends BaseViewModel {
  ValueNotifier<GroupModel?> group = ValueNotifier(null);

  ValueNotifier<List<PostModel>?> posts = ValueNotifier(null);
  ValueNotifier<List<TestModel>?> tests = ValueNotifier(null);
  ValueNotifier<List<StudentModel>?> students = ValueNotifier(null);

  ScrollController postScrollController = ScrollController();
  ScrollController testScrollController = ScrollController();
  ScrollController studentScrollController = ScrollController();

  final int pageSize = 20;

  int pageNumberPost = 0;
  bool isLoadingPost = false;
  bool hasMorePost = true;

  int pageNumberTest = 0;
  bool isLoadingTest = false;
  bool hasMoreTest = true;

  int pageNumberStudent = 0;
  bool isLoadingStudent = false;
  bool hasMoreStudent = true;

  init() async {
    group.value = Get.arguments['group'];

    refreshPost();
    refreshTest();
    refreshStudent();

    postScrollController.addListener(_onScrollPost);
    testScrollController.addListener(_onScrollTest);
    studentScrollController.addListener(_onScrollStudent);
  }

  void refreshPost() async {
    pageNumberPost = 0;
    hasMorePost = true;
    posts.value = [];
    await _loadPost();
  }

  void refreshTest() async {
    pageNumberTest = 0;
    hasMoreTest = true;
    tests.value = [];
    await _loadTest();
  }

  Future<void> refreshStudent() async {
    pageNumberStudent = 0;
    hasMoreStudent = true;
    students.value = [];
    await _loadStudent();
  }

  void _onScrollPost() {
    if (!isLoadingPost &&
        hasMorePost &&
        postScrollController.position.pixels >= postScrollController.position.maxScrollExtent - 300) {
      _loadPost();
    }
  }

  void _onScrollTest() {
    if (!isLoadingTest &&
        hasMoreTest &&
        testScrollController.position.pixels >= testScrollController.position.maxScrollExtent - 300) {
      _loadTest();
    }
  }

  void _onScrollStudent() {
    if (!isLoadingStudent &&
        hasMoreStudent &&
        studentScrollController.position.pixels >= studentScrollController.position.maxScrollExtent - 300) {
      _loadStudent();
    }
  }

  Future<void> _loadPost() async {
    if (isLoadingPost || !hasMorePost) return;

    isLoadingPost = true;

    try {
      NetworkState<List<PostModel>> resultPosts = await groupRepository.getPosts(
          groupId: group.value?.id ?? '', pageSize: pageSize, pageNumber: pageNumberPost);

      if (resultPosts.isSuccess && resultPosts.result != null) {
        if (resultPosts.result!.isEmpty) {
          hasMorePost = false;
        } else {
          final currentPosts = posts.value ?? [];
          posts.value = [...currentPosts, ...resultPosts.result!];
          pageNumberPost += 1;
        }
      } else {
        hasMorePost = false;
      }
    } catch (e) {
      hasMorePost = false;
    } finally {
      isLoadingPost = false;
    }
  }

  Future<void> _loadTest() async {
    if (isLoadingTest || !hasMoreTest) return;

    isLoadingTest = true;

    try {
      NetworkState<List<TestModel>> resultTests = await groupRepository.getTests(
          groupId: group.value?.id ?? '', pageSize: pageSize, pageNumber: pageNumberTest);

      if (resultTests.isSuccess && resultTests.result != null) {
        if (resultTests.result!.isEmpty) {
          hasMoreTest = false;
        } else {
          final currentTests = tests.value ?? [];

          List<TestModel> newTests = [...currentTests, ...resultTests.result!];
          tests.value = newTests;

          await _checkTestSuccess(newTests);
          // tests.value?.forEach(
          //   (element) => logger.e(element.toString()),
          // );
          pageNumberTest += 1;
        }
      } else {
        hasMoreTest = false;
      }
    } catch (e) {
      hasMoreTest = false;
    } finally {
      isLoadingTest = false;
    }
  }

  Future<void> _checkTestSuccess(List<TestModel> testsList) async {
    if (testsList.isEmpty) return;

    for (int i = 0; i < testsList.length; i++) {
      TestModel test = testsList[i];

      if (test.isSuccess == null) {
        NetworkState<TestResultModel> resultHasDetail = await groupRepository.testStudentDetail(testId: test.id);

        if (resultHasDetail.isSuccess && resultHasDetail.result != null) {
          TestModel updatedTest = test.copyWith(isSuccess: true);

          List<TestModel> updatedTests = List.from(tests.value ?? []);
          updatedTests[i] = updatedTest;
          tests.value = updatedTests;
        } else {
          TestModel updatedTest = test.copyWith(isSuccess: false);

          List<TestModel> updatedTests = List.from(tests.value ?? []);
          updatedTests[i] = updatedTest;
          tests.value = updatedTests;
        }
      }
    }
  }

  Future<void> _loadStudent() async {
    if (isLoadingStudent || !hasMoreStudent) return;

    isLoadingStudent = true;

    try {
      NetworkState<List<StudentModel>> resultStudents = await groupRepository.getStudents(
          groupId: group.value?.id ?? '', pageSize: pageSize, pageNumber: pageNumberStudent);

      if (resultStudents.isSuccess && resultStudents.result != null) {
        if (resultStudents.result!.isEmpty) {
          hasMoreStudent = false;
        } else {
          final currentStudents = students.value ?? [];
          students.value = [...currentStudents, ...resultStudents.result!];
          pageNumberStudent += 1;
        }
      } else {
        hasMoreStudent = false;
      }
    } catch (e) {
      hasMoreStudent = false;
    } finally {
      isLoadingStudent = false;
    }
  }

  void startTest(TestModel test) async {
    if (test.startedAt == null || test.expiredAt == null) {
      showToast(title: 'Lỗi hệ thống, vui lòng thử lại sau!', type: ToastificationType.error);
      return;
    }

    bool isExpired = AppUtils.isExpired(test.expiredAt!);

    bool isNotStarted = !AppUtils.isExpired(test.startedAt!);

    if (isExpired) {
      showToast(title: 'Bài kiểm tra đã hết hạn!', type: ToastificationType.error);
    } else if (isNotStarted) {
      showToast(title: 'Chưa đến thời gian làm bài!', type: ToastificationType.info);
    } else {
      setLoading(true);
      NetworkState resultStartTest = await groupRepository.startTest(testId: test.id);
      setLoading(false);
      if (resultStartTest.isSuccess) {
        showToast(title: 'Bắt đầu làm bài kiểm tra', type: ToastificationType.success);
        Get.toNamed(Routers.testDetail, arguments: {'test': test});
      } else {
        showToast(title: resultStartTest.message ?? '', type: ToastificationType.error);
      }
    }
  }

  void startResult(TestModel test) {
    Get.toNamed(Routers.testResult, arguments: {'test': test});
  }
}
