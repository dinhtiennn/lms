import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/app_prefs.dart';

class AllRequestJoinCourseViewModel extends BaseViewModel {
  StudentModel? studentModel;
  ValueNotifier<List<RequestToCourseModel>?> listRequest = ValueNotifier(null);
  ValueNotifier<bool> isLoadingMore = ValueNotifier(false);
  int currentPage = 0;
  bool hasMoreData = true;
  int pageSize = 10;

  init() async {
    studentModel = AppPrefs.getUser<StudentModel>(StudentModel.fromJson);
    await _loadAllRequest();
  }

  Future<void> _loadAllRequest({int pageNumber = 0}) async {
    if (isLoadingMore.value) return;

    if (pageNumber == 0) {
      setLoading(true);
    } else {
      isLoadingMore.value = true;
      isLoadingMore.notifyListeners();
    }

    NetworkState<List<RequestToCourseModel>> resultRequest =
        await courseRepository.getAllRequestToCourseByStudent(
            studentId: studentModel?.id,
            pageNumber: pageNumber,
            pageSize: pageSize);

    if (resultRequest.isSuccess && resultRequest.result != null) {
      if (pageNumber == 0) {
        listRequest.value = resultRequest.result;
      } else {
        List<RequestToCourseModel> currentRequests =
            List.from(listRequest.value ?? []);
        currentRequests.addAll(resultRequest.result!);
        listRequest.value = currentRequests;
      }
      hasMoreData = resultRequest.result!.length >= pageSize;
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
      _loadAllRequest(pageNumber: currentPage + 1);
    }
  }
}
