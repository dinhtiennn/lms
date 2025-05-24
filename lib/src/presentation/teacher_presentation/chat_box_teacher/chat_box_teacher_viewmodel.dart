import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lms/src/configs/configs.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:toastification/toastification.dart';

class ChatBoxTeacherViewModel extends BaseViewModel with StompListener {
  ValueNotifier<List<ChatBoxModel>?> chatboxes = ValueNotifier([]);
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  TextEditingController chatNameController = TextEditingController();
  int pageSize = 10;
  bool hasMoreData = true;
  final ScrollController scrollController = ScrollController();
  final ValueNotifier<List<AccountModel>> selectedUsers = ValueNotifier([]);
  final ValueNotifier<List<AccountModel>> searchResults = ValueNotifier([]);
  final ValueNotifier<bool> isCreatingChat = ValueNotifier(false);
  final ValueNotifier<bool> isSearching = ValueNotifier(false);

  StompService? stompService;
  String? currentUserEmail;
  String? currentUserFullName;

  init() async {
    // Lấy thông tin người dùng hiện tại
    TeacherModel? teacherModel = AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson);
    currentUserEmail = teacherModel?.email;
    currentUserFullName = teacherModel?.fullName;

    if (currentUserEmail == null) {
      logger.e("Không thể lấy thông tin người dùng hiện tại");
      showToast(title: "Vui lòng đăng nhập lại", type: ToastificationType.error);
      return;
    }

    // Kết nối WebSocket
    await setupSocket();

    // Tải danh sách chat box
    await refreshChatBoxs();

    // Thêm scroll listener
    scrollController.addListener(_scrollListener);
  }

  Future<void> setupSocket() async {
    try {
      isLoading.value = true;
      isLoading.notifyListeners();

      stompService = await StompService.instance();

      // Đăng ký nhận thông báo khi chatbox được tạo mới
      stompService?.registerListener(
        type: StompListenType.chatBoxCreate,
        listener: this,
      );

      logger.i("Socket đã được kết nối thành công");
    } catch (e) {
      logger.e("Lỗi khi thiết lập kết nối socket: $e");
      showToast(title: "Không thể kết nối tới máy chủ", type: ToastificationType.error);

      // Thử kết nối lại sau 3 giây
      Future.delayed(Duration(seconds: 3), () {
        logger.i("Đang thử kết nối lại socket sau khi thất bại");
        setupSocket();
      });
    } finally {
      isLoading.value = false;
      isLoading.notifyListeners();
    }
  }

  void _scrollListener() {
    // Kiểm tra vị trí cuộn để tải thêm dữ liệu
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent * 0.8 &&
        !isLoading.value &&
        hasMoreData) {
      loadMoreChatBoxs();
    }
  }

  // Làm mới danh sách chat
  Future<void> refreshChatBoxs() async {
    hasMoreData = true;
    await _loadChatBoxes(isRefresh: true);
  }

  // Tải thêm chat box khi cuộn
  Future<void> loadMoreChatBoxs() async {
    if (!isLoading.value && hasMoreData) {
      await _loadChatBoxes(isLoadMore: true);
    }
  }

  Future<void> _loadChatBoxes({bool isRefresh = false, bool isLoadMore = false}) async {
    isLoading.value = true;
    isLoading.notifyListeners();

    try {
      // Tính offset dựa trên kích thước danh sách hiện tại
      final int offset = isRefresh ? 0 : chatboxes.value?.length ?? 0;

      NetworkState<List<ChatBoxModel>> resultChatBoxs =
          await chatBoxRepository.chatBoxes(pageSize: pageSize, pageNumber: offset);

      if (resultChatBoxs.isSuccess && resultChatBoxs.result != null) {
        final newChatboxs = resultChatBoxs.result!;
        for (var element in newChatboxs) {
          try {
            stompService?.registerListener(type: StompListenType.chatBox, listener: this, chatBoxId: element.id);
          } catch (e) {
            showToast(title: "Không thể kết nối tới máy chủ", type: ToastificationType.error);
          }
        }
        // Nếu làm mới, thay thế toàn bộ danh sách
        if (isRefresh) {
          chatboxes.value = newChatboxs;
        } else {
          // Nếu tải thêm, thêm vào danh sách hiện tại
          final List<ChatBoxModel> updatedList = [...chatboxes.value ?? [], ...newChatboxs];
          chatboxes.value = updatedList;
        }

        // Cập nhật trạng thái tải thêm - nếu số lượng nhận được ít hơn kích thước trang, không còn dữ liệu để tải
        hasMoreData = newChatboxs.length >= pageSize;

        // Thông báo cho người nghe về dữ liệu cập nhật
        chatboxes.notifyListeners();
      } else {
        // Xử lý trạng thái lỗi
        if (isRefresh) {
          chatboxes.value = [];
          chatboxes.notifyListeners();
        }
        hasMoreData = false;
      }
    } catch (e) {
      logger.e("Lỗi khi tải danh sách chat: $e");
      if (isRefresh) {
        chatboxes.value = [];
        chatboxes.notifyListeners();
      }
      hasMoreData = false;
    } finally {
      isLoading.value = false;
      isLoading.notifyListeners();
    }
  }

  @override
  void onStompChatReceived(dynamic data) {
    final result = jsonDecode(data);
    logger.i('Nhận tin nhắn từ WebSocket: $data');

    try {
      MessageModel receivedMessage = MessageModel(
        id: result['id'],
        senderAccount: AccountModel(
            accountUsername: result['senderAccount'],
            accountFullname: result['fullNameSenderAccount'],
            avatar: result['avatarSenderAccount']),
        content: result['content'],
        chatBoxId: result['chatBoxId'],
        createdAt: result['createdAt'] == null ? null : AppUtils.fromUtcStringToVnTime(result['createdAt']),
      );
      List<ChatBoxModel>? currentChatBoxes = chatboxes.value;
      if (currentChatBoxes == null) {
        return;
      }

      final int chatBoxIndex = currentChatBoxes.indexWhere((chatBox) => chatBox.id == receivedMessage.chatBoxId);

      if (chatBoxIndex != -1) {
        List<ChatBoxModel> updatedChatBoxes = List.from(currentChatBoxes);

        ChatBoxModel chatBoxToUpdate = updatedChatBoxes[chatBoxIndex];

        updatedChatBoxes[chatBoxIndex] = ChatBoxModel(
          id: chatBoxToUpdate.id,
          createdAt: chatBoxToUpdate.createdAt,
          createdBy: chatBoxToUpdate.createdBy,
          name: chatBoxToUpdate.name,
          memberAccountUsernames: chatBoxToUpdate.memberAccountUsernames,
          updatedAt: DateTime.now(),
          lastMessage: receivedMessage.content,
          lastMessageAt: receivedMessage.createdAt,
          lastMessageBy: receivedMessage.senderAccount?.accountFullname,
          group: chatBoxToUpdate.group,
        );

        chatboxes.value = updatedChatBoxes;
        chatboxes.notifyListeners();
      }
    } catch (e) {
      logger.e("Lỗi khi xử lý tin nhắn nhận được: $e");
    }
  }

  void goToDetail(ChatBoxModel chatBox) {
    Get.toNamed(Routers.chatBoxDetailTeacher, arguments: {'chatBox': chatBox})?.then((_) {
      refreshChatBoxs();
    });
  }

  Future<void> createNewChatBox({
    required List<AccountModel> members,
  }) async {
    if (currentUserEmail == null) {
      showToast(title: "Không thể xác định người dùng hiện tại", type: ToastificationType.error);
      return;
    }

    if (members.isEmpty) {
      showToast(title: "Vui lòng chọn ít nhất một người dùng", type: ToastificationType.error);
      return;
    }

    try {
      isCreatingChat.value = true;
      isCreatingChat.notifyListeners();

      final request = ChatBoxCreateRequest(
        anotherAccounts: members.map((e) => e.accountUsername).whereType<String>().toList(),
        groupName: chatNameController.text,
        currentAccountUsername: currentUserEmail!,
      );

      logger.i("Gửi yêu cầu tạo chat: ${jsonEncode(request.toJson())}");

      // Gửi yêu cầu qua WebSocket
      // final stompService = await StompService.instance();

      stompService?.send(StompListenType.chatBoxCreate, jsonEncode(request.toJson()));

      // Xóa danh sách người dùng đã chọn
      selectedUsers.value = [];
      selectedUsers.notifyListeners();
    } catch (e) {
      logger.e("Lỗi khi tạo chatbox mới: $e");
      showToast(title: "Không thể tạo cuộc trò chuyện mới", type: ToastificationType.error);
    } finally {
      isCreatingChat.value = false;
      isCreatingChat.notifyListeners();
    }
  }

  void addUserToSelection(AccountModel userEmail) {
    if (!selectedUsers.value.contains(userEmail)) {
      selectedUsers.value = [...selectedUsers.value, userEmail];
      selectedUsers.notifyListeners();
    }
  }

  void removeUserFromSelection(AccountModel user) {
    selectedUsers.value = selectedUsers.value.where((u) => u != user).toList();
    selectedUsers.notifyListeners();
  }

  @override
  void onStompChatBoxCreateReceived(dynamic data) async {
    logger.i('Nhận phản hồi tạo chatbox: $data');

    try {
      // Phân tích dữ liệu phản hồi
      final response = jsonDecode(data);

      if (response != null && response['chatBoxId'] != null) {
        stompService = await StompService.instance();

        // Đăng ký nhận thông báo khi chatbox được tạo mới
        stompService?.registerListener(
          type: StompListenType.chatBox,
          listener: this,
          chatBoxId: response['chatBoxId'],
        );
        ChatBoxModel chatBoxModel = ChatBoxModel().copyWith(
          id: response['chatBoxId'],
          name: response['nameOfChatBox'],
          memberAccountUsernames: AccountModel.listFromJson(response['listMember']),
          createdBy: response['createdBy'],
          group: response['group'],
          createdAt: response['createdAt'] == null ? null : AppUtils.fromUtcStringToVnTime(response['createdAt']),
        );
        Get.toNamed(Routers.chatBoxDetailTeacher, arguments: {'chatBox': chatBoxModel})?.then((_) {
          refreshChatBoxs();
        });
        refreshChatBoxs();
      }
    } catch (e) {
      logger.e('Lỗi khi xử lý phản hồi tạo chatbox: $e');
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();

    // Hủy đăng ký lắng nghe sự kiện WebSocket
    if (stompService != null) {
      stompService!.unregisterListener(
        type: StompListenType.chatBoxCreate,
        listener: this,
      );
    }

    super.dispose();
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      searchResults.value = [];
      searchResults.notifyListeners();
      return;
    }

    try {
      isSearching.value = true;
      isSearching.notifyListeners();
      NetworkState resultSearch = await authRepository.searchUser(keyword: query);
      if (resultSearch.isSuccess && resultSearch.result != null) {
        searchResults.value = resultSearch.result;
        searchResults.notifyListeners();
      }
      // Lọc kết quả để không bao gồm người dùng hiện tại
      List<AccountModel> filteredResults =
          searchResults.value.where((user) => user.accountUsername != currentUserEmail).toList();

      searchResults.value = filteredResults;
      searchResults.notifyListeners();
    } catch (e) {
      logger.e("Lỗi khi tìm kiếm người dùng: $e");
      searchResults.value = [];
      searchResults.notifyListeners();
    } finally {
      isSearching.value = false;
      isSearching.notifyListeners();
    }
  }

  void clearSearch() {
    searchResults.value = [];
    searchResults.notifyListeners();
  }

  void searchUserOrChatBox() async {
    final result = await Get.toNamed(Routers.chatBoxSearchTeacher);

    if (result is AccountModel) {
      createNewChatBox(members: [result]);
    } else if (result is ChatBoxModel) {
      Get.toNamed(Routers.chatBoxDetailTeacher, arguments: {'chatBox': result})?.then((_) {
        refreshChatBoxs();
      });
    }
  }
}
