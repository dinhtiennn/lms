import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';
import 'package:lms/src/utils/utils.dart';
import 'package:toastification/toastification.dart';

class ChatBoxMemberViewModel extends BaseViewModel with StompListener {
  ValueNotifier<ChatBoxModel?> chatBox = ValueNotifier(null);
  ValueNotifier<List<AccountModel>?> searchAccountResults = ValueNotifier(null);
  ValueNotifier<bool> isSearching = ValueNotifier(false);

  StompService? stompService;
  bool _isSocketConnected = false;
  String? currentUserEmail;

  init() async {
    chatBox.value = Get.arguments['chatBox'];

    // Lấy thông tin người dùng hiện tại từ AppPrefs
    StudentModel? studentModel = AppPrefs.getUser<StudentModel>(StudentModel.fromJson);
    currentUserEmail = studentModel?.email;

    await setupSocket();
  }

  Future<void> setupSocket() async {
    try {
      // Kiểm tra kết nối đã được thiết lập chưa
      if (_isSocketConnected && stompService != null) {
        logger.i("Kết nối socket đã tồn tại, không cần thiết lập lại");
        return;
      }

      logger.i("Đang thiết lập kết nối socket...");

      // Khởi tạo hoặc lấy instance của StompService
      stompService = await StompService.instance();

      // Đăng ký listener cho từng loại kênh, xử lý lỗi riêng cho từng loại
      logger.i("Bắt đầu đăng ký các listener cho socket");

      try {
        stompService?.registerListener(type: StompListenType.addMember, listener: this);
        logger.i("✅ Đăng ký thành công listener cho StompListenType.addMember");
      } catch (e) {
        logger.e("❌ Lỗi khi đăng ký listener cho StompListenType.addMember: $e");
      }

      _isSocketConnected = true;
      logger.i("Socket đã được kết nối và đăng ký listener thành công");
    } catch (e) {
      logger.e("Lỗi trong quá trình khởi tạo: $e");
      _isSocketConnected = false;
    }
  }

  void resetSearch(){
    searchAccountResults.value = [];
    searchAccountResults.notifyListeners();
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

      // Gọi API tìm kiếm người dùng
      NetworkState resultSearch = await authRepository.searchUser(keyword: query, chatBoxId: chatBox.value?.id);
      if (resultSearch.isSuccess && resultSearch.result != null) {
        List<AccountModel> results = resultSearch.result;

        // Lọc những người đã có trong nhóm chat
        List<String?> existingMemberUsernames =
            chatBox.value?.memberAccountUsernames?.map((member) => member.accountUsername).toList() ?? [];

        // Lọc ra những người chưa có trong nhóm và không phải là người dùng hiện tại
        List<AccountModel> filteredResults = results
            .where((user) =>
                user.accountUsername != currentUserEmail && !existingMemberUsernames.contains(user.accountUsername))
            .toList();

        searchAccountResults.value = filteredResults;
      } else {
        searchAccountResults.value = [];
      }

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

  void addUserToChat(AccountModel account) async {
    try {
      if (chatBox.value?.id == null) {
        showToast(title: 'Không thể thêm thành viên vào nhóm chat không xác định', type: ToastificationType.error);
        return;
      }

      if (account.accountUsername == null) {
        showToast(title: 'Thông tin người dùng không hợp lệ', type: ToastificationType.error);
        return;
      }

      // Tạo request để gửi đến server
      final memberId = account.accountId ?? '';
      final memberAccount = account.accountUsername ?? '';

      // Kiểm tra kết nối socket
      if (stompService == null || !_isSocketConnected) {
        await setupSocket();
      }

      // Gửi yêu cầu thêm thành viên qua socket
      final request = {
        'chatboxId': chatBox.value!.id,
        'chatBoxName': chatBox.value!.name,
        'chatMemberRequests': [
          {'memberId': memberId, 'memberAccount': memberAccount}
        ],
        'usernameOfRequestor': currentUserEmail
      };

      // Gửi yêu cầu qua socket
      stompService?.send(StompListenType.addMember, jsonEncode(request));

      showToast(title: 'Đã thêm thành viên vào nhóm chat', type: ToastificationType.success);

      // Cập nhật lại danh sách thành viên (có thể cần làm mới dữ liệu từ server)
      await getListMember();

      // Trả về kết quả là chatBox.value sau khi đã cập nhật
      Get.back(result: chatBox.value);
    } catch (e) {
      logger.e("Lỗi khi thêm thành viên: $e");
      showToast(title: 'Không thể thêm thành viên. Vui lòng thử lại sau.', type: ToastificationType.error);
    }
  }

  Future<void> getListMember() async {
    NetworkState<List<AccountModel>> resultMembers = await chatBoxRepository.getMembers(chatBoxId: chatBox.value?.id);
    if (resultMembers.isSuccess && resultMembers.result != null) {
      chatBox.value = chatBox.value?.copyWith(memberAccountUsernames: resultMembers.result);
    }
  }

  Future<void> removeMember(AccountModel account) async {
    try {
      if (chatBox.value?.id == null) {
        showToast(title: 'Không thể xóa thành viên từ nhóm chat không xác định', type: ToastificationType.error);
        return;
      }

      if (account.accountUsername == null) {
        showToast(title: 'Thông tin người dùng không hợp lệ', type: ToastificationType.error);
        return;
      }

      // Kiểm tra xem người dùng hiện tại có quyền xóa thành viên không
      if (chatBox.value?.createdBy != currentUserEmail) {
        showToast(title: 'Bạn không có quyền xóa thành viên từ nhóm chat này', type: ToastificationType.error);
        return;
      }

      // Gọi API xóa thành viên
      NetworkState resultRemoveMember =
          await chatBoxRepository.removeMembers(chatBoxId: chatBox.value?.id, memberUserName: account.accountUsername);

      if (resultRemoveMember.isSuccess) {
        // Cập nhật danh sách thành viên
        getListMember();

        showToast(title: 'Đã xóa thành viên khỏi nhóm chat', type: ToastificationType.success);
      } else {
        showToast(title: 'Không thể xóa thành viên. Vui lòng thử lại sau.', type: ToastificationType.error);
      }
    } catch (e) {
      logger.e("Lỗi khi xóa thành viên: $e");
      showToast(title: 'Không thể xóa thành viên. Vui lòng thử lại sau.', type: ToastificationType.error);
    }
  }
}
