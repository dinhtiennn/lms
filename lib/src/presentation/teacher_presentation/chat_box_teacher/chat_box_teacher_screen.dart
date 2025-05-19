import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/presentation/teacher_presentation/chat_box_teacher/show_create_chat_bottom_sheet.dart';
import 'package:lms/src/resource/model/chat_box_model.dart';
import 'package:lms/src/resource/model/teacher_model.dart';
import 'package:lms/src/utils/app_prefs.dart';
import 'package:lms/src/utils/app_utils.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
                style: TextStyle(color: white),
              ),
              backgroundColor: primary2,
              centerTitle: true,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(Icons.add, color: white),
                  onPressed: () {
                    setState(() {
                      _viewModel.chatNameController.clear();
                      _viewModel.searchResults.value = [];
                      _viewModel.selectedUsers.value = [];
                      showCreateChatBottomSheet(context, _viewModel);
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: white),
                  onPressed: _viewModel.refreshChatBoxs,
                  tooltip: 'Làm mới',
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: _buildChatList(),
                ),
              ],
            ),
            backgroundColor: white,
          );
        });
  }

  Widget _buildChatList() {
    return ValueListenableBuilder<List<ChatBoxModel>?>(
      valueListenable: _viewModel.chatboxes,
      builder: (context, chatboxes, child) {
        if (chatboxes == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primary2),
            ),
          );
        }
        if (chatboxes.isEmpty) {
          return Container(color: white, child: _buildEmptyState());
        }

        return RefreshIndicator(
          onRefresh: _viewModel.refreshChatBoxs,
          color: primary2,
          child: ListView.builder(
            controller: _viewModel.scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chatboxes.length + 1,
            itemBuilder: (context, index) {
              if (index == chatboxes.length) {
                return _buildLoadMoreIndicator();
              }

              return _buildChatBoxItem(chatboxes[index]);
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
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return ValueListenableBuilder<bool>(
      valueListenable: _viewModel.isLoading,
      builder: (context, isLoading, child) {
        if (isLoading && _viewModel.hasMoreData) {
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
    final String timeDisplay = lastMessageTime != null ? _formatMessageTime(lastMessageTime) : '';

    final String displayName = chatBox.name ?? 'Chat không tên';

    final bool isGroup = chatBox.group ?? false;

    final int memberCount = chatBox.memberAccountUsernames?.length ?? 0;

    final String lastMessageBy = chatBox.lastMessageBy ?? '';
    final bool isOwnMessage =
        lastMessageBy.isNotEmpty && lastMessageBy == AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson)?.email;

    return Card(
      color: white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewModel.goToDetail(chatBox),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(isGroup, memberCount, displayName),
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
                          style: styleVerySmall.copyWith(color: grey2),
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

  Widget _buildAvatar(bool isGroup, int memberCount, String displayName) {
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
        alignment: Alignment.center,
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: primary2,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal();

    if (localDateTime.year == now.year && localDateTime.month == now.month && localDateTime.day == now.day) {
      return DateFormat('HH:mm').format(localDateTime);
    } else if (localDateTime.year == now.year && localDateTime.month == now.month && localDateTime.day == now.day - 1) {
      return 'Hôm qua';
    } else if (now.difference(localDateTime).inDays < 7) {
      return DateFormat('E').format(localDateTime);
    } else {
      return DateFormat('dd/MM/yyyy').format(localDateTime);
    }
  }
}
