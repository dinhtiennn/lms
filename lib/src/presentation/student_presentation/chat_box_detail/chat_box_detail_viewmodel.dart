import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:toastification/toastification.dart';
import 'package:image_picker/image_picker.dart';

class ChatBoxDetailViewModel extends BaseViewModel with StompListener {
  ValueNotifier<ChatBoxModel?> chatbox = ValueNotifier(null);
  ValueNotifier<List<MessageModel>?> messages = ValueNotifier([]);
  ValueNotifier<bool> isLoadingMore = ValueNotifier(false);
  ValueNotifier<bool> isSendingMessage = ValueNotifier(false);
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  StompService? stompService;

  int pageSize = 10;
  bool isLoading = false;
  bool hasMoreMessages = true;
  final ValueNotifier<bool> loading = ValueNotifier(false);

  StudentModel? studentModel = AppPrefs.getUser<StudentModel>(StudentModel.fromJson);
  String? currentUserEmail;
  String? currentUserFullName;

  init() async {
    // Lấy thông tin chat box từ tham số
    chatbox.value = Get.arguments['chatBox'];

    // Lấy thông tin người dùng hiện tại
    currentUserEmail = studentModel?.email;
    currentUserFullName = studentModel?.fullName;

    if (chatbox.value == null || currentUserEmail == null) {
      logger.e("Không thể lấy thông tin chatbox hoặc người dùng hiện tại");
      showToast(title: "Đã xảy ra lỗi, vui lòng thử lại", type: ToastificationType.error);
      return;
    }

    // Đăng ký lắng nghe tin nhắn WebSocket
    await setupSocket();

    // Tải tin nhắn ban đầu (chỉ tải 1 lần)
    await initialLoadMessages();

    // Đợi một chút trước khi đăng ký ScrollListener để tránh kích hoạt ngay lập tức
    Future.delayed(Duration(milliseconds: 500), () {
      // Thêm listener cho ScrollController để tải thêm tin nhắn khi cuộn lên
      scrollController.addListener(_scrollListener);
    });
  }

  void _scrollListener() {
    // Chỉ kiểm tra loadmore khi người dùng chủ động cuộn lên
    if (scrollController.hasClients &&
        scrollController.position.pixels <= scrollController.position.minScrollExtent + 50 &&
        !isLoading &&
        hasMoreMessages) {
      // Thêm log để theo dõi
      logger.i("Đang kích hoạt loadMoreMessages từ _scrollListener");
      loadMoreMessages();
    }
  }

  Future<void> setupSocket() async {
    try {
      loading.value = true;

      stompService = await StompService.instance();
      logger.i("Đăng ký lắng nghe tin nhắn cho chatbox ${chatbox.value?.id}");

      if (chatbox.value?.id != null) {
        stompService?.registerListener(
          type: StompListenType.chatBox,
          listener: this,
          chatBoxId: chatbox.value!.id,
        );
      }

      logger.i("WebSocket đã được kết nối thành công");
    } catch (e) {
      logger.e("Lỗi khi thiết lập kết nối WebSocket: $e");
      showToast(title: "Không thể kết nối đến máy chủ", type: ToastificationType.error);

      // Thử kết nối lại sau 3 giây
      Future.delayed(Duration(seconds: 3), () {
        logger.i("Đang thử kết nối lại WebSocket sau khi thất bại");
        setupSocket();
      });
    } finally {
      loading.value = false;
    }
  }

  // Hàm này chỉ dùng để tải tin nhắn lần đầu khi vào màn hình
  Future<void> initialLoadMessages() async {
    hasMoreMessages = true;
    logger.i("Đang tải tin nhắn lần đầu (trang 0)");

    isLoading = true;
    notifyListeners();

    try {
      NetworkState<List<MessageModel>> resultMessages =
          await chatBoxRepository.messages(id: chatbox.value?.id ?? '', pageSize: pageSize, pageNumber: 0);

      if (resultMessages.isSuccess && resultMessages.result != null) {
        final newMessages = resultMessages.result!;
        logger.i("Đã nhận ${newMessages.length} tin nhắn từ lần tải đầu tiên");

        messages.value = newMessages;
        hasMoreMessages = newMessages.length >= pageSize;
        messages.notifyListeners();

        // Cuộn xuống dưới cùng để hiển thị tin nhắn mới nhất
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients && messages.value != null && messages.value!.isNotEmpty) {
            logger.i("Cuộn xuống dưới cùng sau khi tải tin nhắn lần đầu");
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        messages.value = [];
        messages.notifyListeners();
        hasMoreMessages = false;
        logger.w("Không có tin nhắn nào để tải");
      }

      // Đánh dấu tất cả tin nhắn là đã đọc
      await markMessagesAsRead();
    } catch (e) {
      logger.e("Lỗi khi tải tin nhắn lần đầu: $e");
      messages.value = [];
      messages.notifyListeners();
      hasMoreMessages = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshMessages() async {
    hasMoreMessages = true;
    logger.i("Đang làm mới tin nhắn (trang 0)");

    await _loadMessages(isRefresh: true);

    // Đánh dấu tất cả tin nhắn là đã đọc
    await markMessagesAsRead();
  }

  Future<void> loadMoreMessages() async {
    if (!isLoading && hasMoreMessages) {
      logger.i("Đang tải thêm tin nhắn cũ (trang ${(messages.value?.length ?? 0) ~/ pageSize})");
      await _loadMessages(isLoadMore: true);
    }
  }

  Future<void> _loadMessages({bool isRefresh = false, bool isLoadMore = false}) async {
    if (isLoading || chatbox.value?.id == null) return;

    isLoading = true;
    if (isLoadMore) {
      isLoadingMore.value = true;
      isLoadingMore.notifyListeners();
    }
    notifyListeners();

    try {
      // Tính pageNumber dựa trên số lượng tin nhắn hiện tại
      final int pageNumber = isRefresh ? 0 : messages.value?.length ?? 0;

      logger
          .i("Tải tin nhắn: pageNumber=$pageNumber, pageSize=$pageSize, isRefresh=$isRefresh, isLoadMore=$isLoadMore");

      NetworkState<List<MessageModel>> resultMessages =
          await chatBoxRepository.messages(id: chatbox.value?.id ?? '', pageSize: pageSize, pageNumber: pageNumber);

      if (resultMessages.isSuccess && resultMessages.result != null) {
        final newMessages = resultMessages.result!;
        logger.i("Đã nhận ${newMessages.length} tin nhắn mới");

        // Lưu chiều cao trước khi thêm tin nhắn mới nếu đang loadmore
        double? savedHeight;
        if (isLoadMore && scrollController.hasClients) {
          savedHeight = scrollController.position.maxScrollExtent;
        }

        if (isRefresh) {
          // Nếu đang refresh, thay thế danh sách cũ
          messages.value = newMessages;
        } else if (newMessages.isNotEmpty) {
          // Nếu đang loadmore, thêm tin nhắn mới vào đầu danh sách
          final List<MessageModel> updatedList = [...newMessages, ...messages.value ?? []];
          messages.value = updatedList;
        }

        // Cập nhật trạng thái có thể tải thêm
        hasMoreMessages = newMessages.length >= pageSize;
        messages.notifyListeners();

        // Xử lý vị trí cuộn sau khi cập nhật danh sách
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            if (isRefresh && messages.value != null && messages.value!.isNotEmpty) {
              // Nếu refresh, cuộn xuống dưới cùng
              logger.i("Cuộn xuống dưới cùng sau khi refresh");
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            } else if (isLoadMore && savedHeight != null) {
              // Khi loadmore, giữ vị trí cuộn tương đối
              final double newHeight = scrollController.position.maxScrollExtent;
              final double offset = newHeight - savedHeight;

              // Giữ vị trí tương đối bằng cách nhảy đến vị trí mới
              logger.i("Giữ vị trí cuộn sau khi loadmore: offset=$offset");
              scrollController.jumpTo(scrollController.position.pixels + offset);
            }
          }
        });
      } else {
        if (isRefresh) {
          messages.value = [];
          messages.notifyListeners();
        }
        hasMoreMessages = false;
        logger.w("Không có thêm tin nhắn nào để tải");
      }
    } catch (e) {
      logger.e("Lỗi khi tải tin nhắn: $e");
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

  Future<void> markMessagesAsRead() async {
    if (chatbox.value?.id == null) return;

    try {
      NetworkState resultReadMessage = await chatBoxRepository.markAsRead(chatBoxId: chatbox.value?.id);
      if (resultReadMessage.isSuccess) {
        logger.i("Đã đánh dấu tin nhắn là đã đọc");
      } else {
        logger.e("Lỗi khi đánh dấu tin nhắn là đã đọc: ${resultReadMessage.message}");
      }
    } catch (e) {
      logger.e("Lỗi khi đánh dấu tin nhắn là đã đọc: $e");
    }
  }

  @override
  void onStompChatReceived(dynamic data) {
    logger.i('Nhận tin nhắn từ WebSocket: $data');
    try {
      final response = jsonDecode(data);
      MessageModel receivedMessage = MessageModel(
        createdAt: response['createdAt'] == null ? null : AppUtils.fromUtcStringToVnTime(response['createdAt']),
        chatBoxId: response['chatBoxId'],
        id: response['id'],
        content: response['content'],
        senderAccount: AccountModel(
            avatar: response['avatarSenderAccount'],
            accountFullname: response['fullNameSenderAccount'],
            accountUsername: response['senderAccount']),
      );

      // Kiểm tra nếu tin nhắn này chưa có trong danh sách
      final existingIndex = messages.value?.indexWhere((msg) => msg.id == receivedMessage.id) ?? -1;

      if (existingIndex == -1) {
        // Thêm tin nhắn mới vào danh sách
        messages.value = [...messages.value ?? [], receivedMessage];
        messages.notifyListeners();

        // Cuộn xuống tin nhắn mới
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else if (messages.value != null) {
        // Cập nhật tin nhắn hiện có (ví dụ: trạng thái đã đọc)
        final updatedMessages = [...messages.value!];
        updatedMessages[existingIndex] = receivedMessage;
        messages.value = updatedMessages;
        messages.notifyListeners();
      }

      // Đánh dấu tin nhắn là đã đọc
      markMessagesAsRead();
    } catch (e) {
      logger.e("Lỗi khi xử lý tin nhắn nhận được: $e");
    }
  }

  Future<void> sendMessage() async {
    if (chatbox.value?.id == null || currentUserEmail == null) {
      showToast(title: "Không thể xác định thông tin cuộc trò chuyện hoặc người dùng", type: ToastificationType.error);
      return;
    }

    if (messageController.text.isEmpty) {
      return;
    }

    try {
      isSendingMessage.value = true;
      isSendingMessage.notifyListeners();

      // Gửi tin nhắn văn bản qua WebSocket
      final messageRequest = {
        'chatBoxId': chatbox.value!.id,
        'senderAccount': currentUserEmail,
        'content': messageController.text.trim()
      };

      stompService!.send(
        StompListenType.chatBox,
        jsonEncode(messageRequest),
      );

      messageController.clear();
    } catch (e) {
      logger.e("Lỗi khi gửi tin nhắn: $e");
      showToast(title: "Không thể gửi tin nhắn. Vui lòng thử lại", type: ToastificationType.error);
    } finally {
      isSendingMessage.value = false;
      isSendingMessage.notifyListeners();
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();

    // Hủy đăng ký lắng nghe tin nhắn từ WebSocket
    if (stompService != null && chatbox.value?.id != null) {
      stompService!.unregisterListener(
        type: StompListenType.chatBox,
        listener: this,
        chatBoxId: chatbox.value!.id,
      );
    }

    super.dispose();
  }

  void settingBoxChat() async {
    try {
      dynamic result = await Get.toNamed(Routers.chatBoxInfo, arguments: {'chatBox': chatbox.value});
      if (result != null) {
        chatbox.value = result;
        chatbox.notifyListeners();
        logger.i("Đã cập nhật thông tin chatbox từ màn hình cài đặt");
      }
    } catch (e) {
      logger.e("Lỗi khi cập nhật thông tin chatbox: $e");
    }
  }
}
