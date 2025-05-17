import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/chat_box_model.dart';
import 'package:lms/src/resource/model/teacher_model.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:lms/src/utils/app_utils.dart';

class ChatBoxTeacherScreen extends StatefulWidget {
  const ChatBoxTeacherScreen({Key? key}) : super(key: key);

  @override
  State<ChatBoxTeacherScreen> createState() => _ChatBoxTeacherScreenState();
}

class _ChatBoxTeacherScreenState extends State<ChatBoxTeacherScreen> {
  late ChatBoxTeacherViewModel _viewModel;

  final Color grey0 = Colors.grey.shade200;
  final Color grey1 = Colors.grey.shade400;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<ChatBoxTeacherViewModel>(
        viewModel: ChatBoxTeacherViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _viewModel.init();
          });
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Tin nhắn',
                style: styleLargeBold.copyWith(color: white),
              ),
              backgroundColor: primary2,
              centerTitle: true,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: white),
                  onPressed: _viewModel.refreshChatBoxs,
                  tooltip: 'Làm mới',
                ),
              ],
            ),
            body: SafeArea(child: _buildBody()),
            backgroundColor: white,
          );
        });
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _buildChatList(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: primary2.withOpacity(0.05),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm cuộc trò chuyện...',
                  hintStyle: styleSmall.copyWith(color: grey1),
                  prefixIcon: Icon(Icons.search, color: grey1),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ValueListenableBuilder<List<ChatBoxModel>?>(
      valueListenable: _viewModel.chatboxs,
      builder: (context, chatboxs, child) {
        if (chatboxs == null) {
          return const Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primary2),
          ));
        }

        if (chatboxs.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _viewModel.refreshChatBoxs,
          color: primary2,
          child: ListView.builder(
            controller: _viewModel.scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chatboxs.length + 1,
            itemBuilder: (context, index) {
              if (index == chatboxs.length) {
                return _buildLoadMoreIndicator();
              }

              return _buildChatBoxItem(chatboxs[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary2.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: primary2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Không có cuộc trò chuyện nào',
            style: styleMediumBold.copyWith(color: grey3),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy bắt đầu trò chuyện mới',
            style: styleSmall.copyWith(color: grey1),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _viewModel.refreshChatBoxs,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary2,
              foregroundColor: white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Làm mới'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return ValueListenableBuilder<bool>(
      valueListenable:
          ValueNotifier(_viewModel.isLoading && _viewModel.hasMoreData),
      builder: (context, isLoading, child) {
        if (isLoading) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(primary2),
              ),
            ),
          );
        }

        if (!_viewModel.hasMoreData) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Bạn đã xem hết cuộc trò chuyện',
                style: styleSmall.copyWith(color: grey1),
              ),
            ),
          );
        }

        return const SizedBox(height: 16);
      },
    );
  }

  Widget _buildChatBoxItem(ChatBoxModel chatBox) {
    final DateTime? lastMessageTime = chatBox.lastMessageAt;
    final String timeDisplay =
        lastMessageTime != null ? _formatMessageTime(lastMessageTime) : '';

    final String displayName = chatBox.name ?? 'Chat không tên';

    final bool isGroup = chatBox.group ?? false;

    final int memberCount = chatBox.memberAccountUsernames?.length ?? 0;

    final String lastMessageBy = chatBox.lastMessageBy ?? '';
    final bool isOwnMessage = lastMessageBy.isNotEmpty &&
        lastMessageBy ==
            AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson)?.email;

    return Card(
      color: primary2.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: grey0, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.toNamed(Routers.chatBoxDetailTeacher, arguments: {'chatBox': chatBox});
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(isGroup, memberCount),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: styleMediumBold.copyWith(color: grey3),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeDisplay,
                          style: styleVerySmall.copyWith(color: grey1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    chatBox.lastMessage != null
                        ? Text(
                            isGroup && !isOwnMessage
                                ? '$lastMessageBy: ${chatBox.lastMessage}'
                                : isOwnMessage
                                    ? 'Bạn: ${chatBox.lastMessage}'
                                    : chatBox.lastMessage!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: styleSmall.copyWith(color: grey2),
                          )
                        : Text(
                            'Không có tin nhắn',
                            style: styleSmall.copyWith(
                              color: grey1,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isGroup, int memberCount) {
    if (isGroup) {
      return Stack(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primary2.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people,
              color: primary2,
              size: 24,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: primary2,
                shape: BoxShape.circle,
                border: Border.all(color: white, width: 2),
              ),
              child: Text(
                memberCount.toString(),
                style: const TextStyle(
                  color: white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: primary2.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person,
          color: primary2,
          size: 24,
        ),
      );
    }
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal();

    if (localDateTime.year == now.year &&
        localDateTime.month == now.month &&
        localDateTime.day == now.day) {
      return DateFormat('HH:mm').format(localDateTime);
    } else if (localDateTime.year == now.year &&
        localDateTime.month == now.month &&
        localDateTime.day == now.day - 1) {
      return 'Hôm qua';
    } else if (now.difference(localDateTime).inDays < 7) {
      return DateFormat('E').format(localDateTime);
    } else {
      return DateFormat('dd/MM/yyyy').format(localDateTime);
    }
  }
}
