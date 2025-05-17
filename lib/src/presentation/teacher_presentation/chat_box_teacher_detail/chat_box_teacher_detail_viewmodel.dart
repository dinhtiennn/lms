import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/app_prefs.dart';

class ChatBoxTeacherDetailViewModel extends BaseViewModel {
  ValueNotifier<ChatBoxModel?> chatbox = ValueNotifier(null);
  ValueNotifier<List<MessageModel>?> messages = ValueNotifier([]);
  ValueNotifier<bool> isLoadingMore = ValueNotifier(false);
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  // Pagination parameters
  int pageSize = 20;
  bool isLoading = false;
  bool hasMoreMessages = true;

  // User information
  String? currentUserEmail;

  init() async {
    // Get the chatbox from arguments
    chatbox.value = Get.arguments['chatBox'];

    // Get current user email for message identification
    currentUserEmail =
        AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson)?.email;

    // Set up scroll listener for loading more messages when scrolling up
    scrollController.addListener(_scrollListener);

    // Load initial messages
    await refreshMessages();
  }

  void _scrollListener() {
    // Load more when scrolling to the top (older messages)
    if (scrollController.position.pixels <=
            scrollController.position.minScrollExtent + 200 &&
        !isLoading &&
        hasMoreMessages) {
      loadMoreMessages();
    }
  }

  // Refresh messages (initial load)
  Future<void> refreshMessages() async {
    hasMoreMessages = true;
    await _loadMessages(isRefresh: true);

    // Không tự động cuộn xuống dưới sau khi load tin nhắn lần đầu
    // vì chúng ta muốn hiển thị tin nhắn cũ nhất ở trên cùng
  }

  // Load more messages (older messages)
  Future<void> loadMoreMessages() async {
    if (!isLoading && hasMoreMessages) {
      await _loadMessages(isLoadMore: true);
    }
  }

  Future<void> _loadMessages(
      {bool isRefresh = false, bool isLoadMore = false}) async {
    if (isLoading || chatbox.value?.id == null) return;

    isLoading = true;
    if (isLoadMore) {
      isLoadingMore.value = true;
      isLoadingMore.notifyListeners();
    }
    notifyListeners();

    try {
      // Calculate offset based on current list size
      final int offset = isRefresh ? 0 : messages.value?.length ?? 0;

      NetworkState<List<MessageModel>> resultMessages =
          await chatBoxRepository.messages(
              id: chatbox.value?.id ?? '',
              pageSize: pageSize,
              pageNumber: offset);

      if (resultMessages.isSuccess && resultMessages.result != null) {
        final newMessages = resultMessages.result!;

        // If refreshing, replace the entire list
        if (isRefresh) {
          messages.value = newMessages;
        } else {
          // If loading more, prepend to the existing list (older messages go at the top)
          final List<MessageModel> updatedList = [
            ...newMessages,
            ...messages.value ?? []
          ];
          messages.value = updatedList;
        }

        // Update hasMoreMessages flag - if we got fewer items than pageSize, there are no more to load
        hasMoreMessages = newMessages.length >= pageSize;

        // Notify listeners
        messages.notifyListeners();
      } else {
        // Handle error state
        if (isRefresh) {
          messages.value = [];
          messages.notifyListeners();
        }
        hasMoreMessages = false;
      }
    } catch (e) {
      logger.e("Error loading messages: $e");
      if (isRefresh) {
        messages.value = [];
        messages.notifyListeners();
      }
      hasMoreMessages = false;
    } finally {
      isLoading = false;
      if (isLoadMore) {
        isLoadingMore.value = false;
        isLoadingMore.notifyListeners();
      }
      notifyListeners();
    }
  }

  // Send a new message
  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty || chatbox.value?.id == null)
      return;

    final String messageContent = messageController.text.trim();
    messageController.clear();

    try {
      // Add the new message locally for immediate feedback
      final newMessage = MessageModel(
        chatBoxId: chatbox.value?.id,
        senderAccount: currentUserEmail,
        content: messageContent,
        createdAt: DateTime.now(),
      );

      // Add to message list - thêm vào cuối danh sách (tin nhắn mới nhất)
      messages.value = [...messages.value ?? [], newMessage];
      messages.notifyListeners();

      // Scroll to bottom to show the new message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      // TODO: Implement actual message sending API call
      // For now we'll just add the message locally for demo purposes
      /*
      final result = await chatBoxRepository.sendMessage(
        id: chatbox.value?.id ?? '',
        content: messageContent
      );
      */
    } catch (e) {
      logger.e("Error sending message: $e");
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }
}
