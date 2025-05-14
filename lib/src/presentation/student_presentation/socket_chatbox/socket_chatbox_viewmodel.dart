import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/resource.dart';

// class SocketChatBoxViewModel extends BaseViewModel with StompListener {
class SocketChatBoxViewModel extends BaseViewModel {
  TextEditingController controller = TextEditingController();
  ValueNotifier<List<String>> messages = ValueNotifier([]);
  // late StompService stompService;

  init() async {
    // _setupSocket();
  }

  // void _setupSocket() async {
  //   stompService = await StompService.instance();
  //   // Đăng ký listener
  //   stompService.registerListener(type: StompListenType.chatBox, listener: this);
  // }

  // Gửi tin nhắn khi người dùng bấm gửi
  // void sendMessage() {
  //   if (controller.text.isNotEmpty) {
  //     // Gửi tin nhắn qua STOMP
  //     stompService.send(
  //       StompListenType.chatBox,
  //       'Nội dung tin nhắn chat',
  //     );
  //
  //     // Hiển thị tin nhắn đã gửi trong UI
  //     messages.value.add('Me: ${controller.text}');
  //     messages.notifyListeners();
  //     controller.clear();
  //   }
  // }

  @override
  void onStompChatReceived(dynamic data) {
    // Giả sử data là một tin nhắn chat
    String receivedMessage = data['content']; // Ví dụ nhận tin nhắn
    messages.value.add('Received: $receivedMessage');
    messages.notifyListeners();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // Hủy lắng nghe chatBox
    // stompService.unregisterListener(type: StompListenType.chatBox, listener: this);
  }
}
