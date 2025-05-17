import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_utils.dart';

class ChatBoxTeacherViewModel extends BaseViewModel {
  ValueNotifier<List<ChatBoxModel>?> chatboxs = ValueNotifier([]);
  int pageSize = 10;
  bool isLoading = false;
  bool hasMoreData = true;
  final ScrollController scrollController = ScrollController();

  init() async {
    // Add scroll listener for automatic loading more data
    scrollController.addListener(_scrollListener);

    // Initial load
    await refreshChatBoxs();
  }

  void _scrollListener() {
    // Check if we're near the bottom of the list
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent * 0.8 &&
        !isLoading &&
        hasMoreData) {
      loadMoreChatBoxs();
    }
  }

  // Pull-to-refresh functionality
  Future<void> refreshChatBoxs() async {
    hasMoreData = true;
    await _loadChatBoxs(isRefresh: true);
  }

  // Load more functionality
  Future<void> loadMoreChatBoxs() async {
    if (!isLoading && hasMoreData) {
      await _loadChatBoxs(isLoadMore: true);
    }
  }

  Future<void> _loadChatBoxs(
      {bool isRefresh = false, bool isLoadMore = false}) async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      // Calculate offset based on current list size
      final int offset = isRefresh ? 0 : chatboxs.value?.length ?? 0;

      NetworkState<List<ChatBoxModel>> resultChatBoxs = await chatBoxRepository
          .chatBoxs(pageSize: pageSize, pageNumber: offset);

      if (resultChatBoxs.isSuccess && resultChatBoxs.result != null) {
        final newChatboxs = resultChatBoxs.result!;

        // If refreshing, replace the entire list
        if (isRefresh) {
          chatboxs.value = newChatboxs;
        } else {
          // If loading more, append to the existing list
          final List<ChatBoxModel> updatedList = [
            ...chatboxs.value ?? [],
            ...newChatboxs
          ];
          chatboxs.value = updatedList;
        }

        // Update hasMoreData flag - if we got fewer items than pageSize, there are no more to load
        hasMoreData = newChatboxs.length >= pageSize;

        // Notify listeners about the updated data
        chatboxs.notifyListeners();
      } else {
        // Handle error state
        if (isRefresh) {
          chatboxs.value = [];
          chatboxs.notifyListeners();
        }
        hasMoreData = false;
      }
    } catch (e) {
      logger.e("Error loading chat boxes: $e");
      if (isRefresh) {
        chatboxs.value = [];
        chatboxs.notifyListeners();
      }
      hasMoreData = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }
}
