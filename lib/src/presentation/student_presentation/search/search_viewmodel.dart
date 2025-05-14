import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';

class SearchViewModel extends BaseViewModel {
  TextEditingController searchController = TextEditingController();
  ValueNotifier<List<CourseModel>> courseOfMyMajor = ValueNotifier([]);
  ValueNotifier<List<CourseModel>> courseSearch = ValueNotifier([]);

  ValueNotifier<bool> isSearching = ValueNotifier(false);
  ValueNotifier<bool> isLoadingMore = ValueNotifier(false);
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  int currentPageMajor = 0;
  int currentPageSearch = 0;

  init() async {
    searchController.addListener(_onSearchChanged);
    isSearching.value = false;
    await getCoursesOfMyMajor();
  }

  void _onSearchChanged() {
    if (searchController.text.isEmpty) {
      isSearching.value = false;
      isSearching.notifyListeners();
    } else {
      isSearching.value = true;
      isSearching.notifyListeners();
      currentPageSearch = 0;
      getCoursesSearch();
    }
  }

  Future<void> getCoursesOfMyMajor(
      {int pageSize = 10, int pageNumber = 0}) async {
    if (isLoadingMore.value) {
      return;
    }

    if (pageNumber == 0) {
      isLoading.value = true;
      isLoading.notifyListeners();
    } else {
      isLoadingMore.value = true;
      isLoadingMore.notifyListeners();
    }

    NetworkState<List<CourseModel>> resultCourseOfMyMajor =
        await courseRepository.courseOfMajorFirst(
            pageSize: pageSize, pageNumber: pageNumber);

    if (resultCourseOfMyMajor.isSuccess &&
        resultCourseOfMyMajor.result != null) {
      if (pageNumber == 0) {
        courseOfMyMajor.value = resultCourseOfMyMajor.result ?? [];
      } else {
        List<CourseModel> currentCourses = List.from(courseOfMyMajor.value);
        currentCourses.addAll(resultCourseOfMyMajor.result ?? []);
        courseOfMyMajor.value = currentCourses;
      }
      courseOfMyMajor.notifyListeners();
      currentPageMajor = pageNumber;
    }

    if (pageNumber == 0) {
      isLoading.value = false;
      isLoading.notifyListeners();
    } else {
      isLoadingMore.value = false;
      isLoadingMore.notifyListeners();
    }
  }

  Future<void> getCoursesSearch({int pageSize = 10, int pageNumber = 0}) async {
    if (searchController.text.isEmpty) return;

    if (isLoadingMore.value) {
      return;
    }

    if (pageNumber == 0) {
      isLoading.value = true;
      isLoading.notifyListeners();
    } else {
      isLoadingMore.value = true;
      isLoadingMore.notifyListeners();
    }

    NetworkState<List<CourseModel>> resultCourseSearch =
        await courseRepository.searchCourses(
            keyword: searchController.text,
            pageSize: pageSize,
            pageNumber: pageNumber);

    if (resultCourseSearch.isSuccess && resultCourseSearch.result != null) {
      if (pageNumber == 0) {
        courseSearch.value = resultCourseSearch.result ?? [];
      } else {
        List<CourseModel> currentCourses = List.from(courseSearch.value);
        currentCourses.addAll(resultCourseSearch.result ?? []);
        courseSearch.value = currentCourses;
      }
      courseSearch.notifyListeners();
      currentPageSearch = pageNumber;
    }

    if (pageNumber == 0) {
      isLoading.value = false;
      isLoading.notifyListeners();
    } else {
      isLoadingMore.value = false;
      isLoadingMore.notifyListeners();
    }
  }

  void loadMoreCourses() {
    if (!isLoadingMore.value) {
      if (isSearching.value) {
        getCoursesSearch(pageNumber: currentPageSearch + 1);
      } else {
        getCoursesOfMyMajor(pageNumber: currentPageMajor + 1);
      }
    }
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}
