import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/utils.dart';

class ChatBoxSearchTeacherViewModel extends BaseViewModel {
  final ValueNotifier<List<AccountModel>> searchAccountResults = ValueNotifier([]);
  final ValueNotifier<List<ChatBoxModel>> searchChatBoxResults = ValueNotifier([]);
  final ValueNotifier<bool> isSearching = ValueNotifier(false);
  String? currentUserEmail;

  init() async {
    TeacherModel? teacherModel = AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson);
    currentUserEmail = teacherModel?.email;
  }

  Future<void> searchAccounts(String query) async {
    if (query.isEmpty) {
      searchAccountResults.value = [];
      searchAccountResults.notifyListeners();
      return;
    }

    try {
      isSearching.value = true;
      isSearching.notifyListeners();
      NetworkState resultSearch = await authRepository.searchUser(keyword: query);
      if (resultSearch.isSuccess && resultSearch.result != null) {
        searchAccountResults.value = resultSearch.result;
        searchAccountResults.notifyListeners();
      }
      // Lọc kết quả để không bao gồm người dùng hiện tại
      List<AccountModel> filteredResults =
          searchAccountResults.value.where((user) => user.accountUsername != currentUserEmail).toList();

      searchAccountResults.value = filteredResults;
      searchAccountResults.notifyListeners();
    } catch (e) {
      logger.e("Lỗi khi tìm kiếm người dùng: $e");
      searchAccountResults.value = [];
      searchAccountResults.notifyListeners();
    } finally {
      isSearching.value = false;
      isSearching.notifyListeners();
    }
  }

  Future<void> searchChatBox(String query) async {
    if (query.isEmpty) {
      searchChatBoxResults.value = [];
      searchChatBoxResults.notifyListeners();
      return;
    }

    try {
      isSearching.value = true;
      isSearching.notifyListeners();
      NetworkState<List<ChatBoxModel>> resultSearch = await authRepository.searchChatBox(keyword: query);
      if (resultSearch.isSuccess && resultSearch.result != null) {
        searchChatBoxResults.value = resultSearch.result ?? [];
        searchChatBoxResults.notifyListeners();
      }
    } catch (e) {
      logger.e("Lỗi khi tìm kiếm người dùng: $e");
      searchChatBoxResults.value = [];
      searchChatBoxResults.notifyListeners();
    } finally {
      isSearching.value = false;
      isSearching.notifyListeners();
    }
  }

  void select<T>(T selectedItem) {
    Get.back(result: selectedItem);
  }
}
