import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/main.dart';
import 'package:lms/src/configs/configs.dart';

import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/chat_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatViewModel _viewModel;

  final List<ChatInfoModel> _chats = [
    ChatInfoModel(
      name: "Nguyễn Văn A",
      avatarUrl: "https://picsum.photos/id/1/200",
      lastMessage: "Hẹn gặp lại bạn vào ngày mai nhé!",
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      isOnline: true,
      hasUnreadMessage: true,
      unreadCount: 3,
    ),
    ChatInfoModel(
      name: "Trần Thị B",
      avatarUrl: "https://picsum.photos/id/2/200",
      lastMessage: "Đồng ý, tôi sẽ gửi tài liệu cho bạn.",
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      isOnline: true,
    ),
    ChatInfoModel(
      name: "Nhóm Làm Việc",
      avatarUrl: "https://picsum.photos/id/3/200",
      lastMessage: "Anh Hùng: Chốt deadline vào thứ 6 nhé mọi người!",
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      isOnline: false,
      hasUnreadMessage: true,
      unreadCount: 5,
    ),
    ChatInfoModel(
      name: "Lê Văn C",
      avatarUrl: "https://picsum.photos/id/4/200",
      lastMessage: "Bạn đã: Gửi một hình ảnh",
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      isOnline: false,
    ),
    ChatInfoModel(
      name: "Phạm Thị D",
      avatarUrl: "https://picsum.photos/id/5/200",
      lastMessage: "Cảm ơn bạn rất nhiều!",
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      isOnline: true,
    ),
    ChatInfoModel(
      name: "Hoàng Văn E",
      avatarUrl: "https://picsum.photos/id/6/200",
      lastMessage: "Ok bạn.",
      lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
      isOnline: false,
    ),
    ChatInfoModel(
      name: "Bùi Thị F",
      avatarUrl: "https://picsum.photos/id/7/200",
      lastMessage: "Hẹn gặp lại bạn vào tuần sau nhé!",
      lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
      isOnline: false,
      hasUnreadMessage: true,
      unreadCount: 1,
    ),
    ChatInfoModel(
      name: "Đặng Văn G",
      avatarUrl: "https://picsum.photos/id/8/200",
      lastMessage: "Bạn đã: Đã gửi một file",
      lastMessageTime: DateTime.now().subtract(const Duration(days: 4)),
      isOnline: true,
    ),
    ChatInfoModel(
      name: "Vũ Thị H",
      avatarUrl: "https://picsum.photos/id/9/200",
      lastMessage: "Tôi sẽ liên hệ với bạn sau.",
      lastMessageTime: DateTime.now().subtract(const Duration(days: 5)),
      isOnline: false,
    ),
    ChatInfoModel(
      name: "Nhóm Bạn Thân",
      avatarUrl: "https://picsum.photos/id/10/200",
      lastMessage: "Mai: Cuối tuần này đi chơi đâu nhỉ?",
      lastMessageTime: DateTime.now().subtract(const Duration(days: 5)),
      isOnline: false,
    ),
  ];

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inMinutes < 60) {
      return '${now.difference(time).inMinutes} phút';
    } else if (now.difference(time).inHours < 24) {
      return '${now.difference(time).inHours} giờ';
    } else if (now.difference(time).inDays < 7) {
      return '${now.difference(time).inDays} ngày';
    } else {
      return '${time.day}/${time.month}';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return BaseWidget<ChatViewModel>(
        viewModel: ChatViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel..init();
        },
        // child: WidgetBackground(),
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primary2,
              elevation: 0,
              title: Text(
                'Chat'.tr,
                style: styleLargeBold.copyWith(color: white),
              ),
              centerTitle: true,
            ),
            body: SafeArea(child: _buildBody()),
            backgroundColor: white,
          );
        });
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: 'Tìm kiếm',
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Danh sách chat
          Expanded(
            child: ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(chat.avatarUrl),
                      ),
                      if (chat.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    chat.name,
                    style: TextStyle(
                      fontWeight: chat.hasUnreadMessage ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    chat.lastMessage,
                    style: TextStyle(
                      color: chat.hasUnreadMessage ? Colors.black : Colors.grey,
                      fontWeight: chat.hasUnreadMessage ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(chat.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: chat.hasUnreadMessage ? Colors.blue : Colors.grey,
                          fontWeight: chat.hasUnreadMessage ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (chat.hasUnreadMessage)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    // Xử lý khi nhấn vào cuộc trò chuyện
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
