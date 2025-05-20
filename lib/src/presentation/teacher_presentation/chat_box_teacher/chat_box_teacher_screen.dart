import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/presentation/teacher_presentation/chat_box_teacher/show_create_chat_bottom_sheet.dart';
import 'package:lms/src/resource/model/account_model.dart';
import 'package:lms/src/resource/model/chat_box_model.dart';
import 'package:lms/src/resource/model/teacher_model.dart';
import 'package:lms/src/utils/app_prefs.dart';

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
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: WidgetInput(
                    hintText: 'Tên người dùng, email, đoạn chat...',
                    prefix: const Icon(Icons.search, color: grey2),
                    borderRadius: BorderRadius.circular(12),
                    widthPrefix: 40,
                    style: styleSmall.copyWith(color: grey2),
                    readOnly: true,
                    onTap: () {
                      _viewModel.searchUserOrChatBox();
                    },
                  ),
                ),
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
          return RefreshIndicator(
            onRefresh: _viewModel.refreshChatBoxs,
            color: primary2,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Container(
                  height: MediaQuery.of(context).size.height - 150,
                  color: white,
                  child: _buildEmptyState(),
                ),
              ],
            ),
          );
        }

        // Lấy chiều cao màn hình để đảm bảo nội dung luôn có thể cuộn
        final screenHeight = MediaQuery.of(context).size.height;

        return RefreshIndicator(
          onRefresh: _viewModel.refreshChatBoxs,
          color: primary2,
          child: ListView.builder(
            // Đảm bảo luôn có thể cuộn
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _viewModel.scrollController,
            // Padding đủ lớn ở dưới cùng để đảm bảo có thể cuộn khi ít mục
            padding: EdgeInsets.only(
              top: 8,
              bottom: chatboxes.length < 5
                  ? screenHeight * 0.6
                  : 16, // Thêm padding lớn nếu ít mục
              left: 0,
              right: 0,
            ),
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
          const SizedBox(height: 16),
          Text(
            'Kéo xuống để làm mới',
            style: styleVerySmall.copyWith(color: grey1),
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
    final String timeDisplay =
        lastMessageTime != null ? _formatMessageTime(lastMessageTime) : '';

    final bool isGroup = chatBox.group ?? false;

    // Lấy thông tin người dùng hiện tại
    final TeacherModel? currentUser =
        AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson);
    final String currentUserEmail = currentUser?.email ?? '';

    // Xác định tên hiển thị và thông tin người đối diện
    String displayName = '';
    AccountModel? otherUser;

    if (isGroup) {
      // Nếu là nhóm chat, hiển thị tên nhóm
      displayName = chatBox.name ?? 'Nhóm không tên';
    } else {
      // Nếu là chat 1-1, tìm người đối diện
      if (chatBox.memberAccountUsernames != null &&
          chatBox.memberAccountUsernames!.isNotEmpty) {
        // Tìm tài khoản không phải là người dùng hiện tại
        otherUser = chatBox.memberAccountUsernames!.firstWhere(
            (member) => member.accountUsername != chatBox.createdBy,
            orElse: () => chatBox.memberAccountUsernames!.first);

        // Lấy tên hiển thị từ tài khoản đối diện
        displayName = otherUser.accountFullname ??
            otherUser.accountUsername ??
            'Người dùng không tên';
      } else {
        displayName = 'Chat không tên';
      }
    }

    final String lastMessageBy = chatBox.lastMessageBy ?? '';
    final bool isOwnMessage =
        lastMessageBy.isNotEmpty && lastMessageBy == currentUserEmail;

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
              isGroup
                  ? _buildAvatar(
                      true, chatBox.memberAccountUsernames ?? [], displayName)
                  : _buildSingleUserAvatar(otherUser, displayName),
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

  Widget _buildSingleUserAvatar(AccountModel? user, String displayName) {
    // Nếu có thông tin người dùng và có avatar
    if (user != null && user.avatar != null && user.avatar!.isNotEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: WidgetImageNetwork(
          url: user.avatar!,
          fit: BoxFit.cover,
          widgetError: _buildDefaultAvatar(displayName),
        ),
      );
    } else {
      // Nếu không có avatar, hiển thị chữ cái đầu tiên
      return _buildDefaultAvatar(displayName);
    }
  }

  Widget _buildDefaultAvatar(String displayName) {
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

  Widget _buildAvatar(
      bool isGroup, List<AccountModel> members, String displayName) {
    int memberCount = members.length;

    if (isGroup) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: white,
          shape: BoxShape.circle,
          border: Border.all(color: primary2.withOpacity(0.2), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: memberCount > 0
            ? _buildGroupAvatars(members)
            : const Icon(
                Icons.people,
                color: primary2,
                size: 24,
              ),
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

  Widget _buildGroupAvatars(List<AccountModel> members) {
    final displayMembers = members.take(3).toList();

    return Column(
      children: [
        // Nửa trên: 1 avatar
        if (displayMembers.isNotEmpty)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: _buildSingleAvatar(displayMembers[0], 0),
            ),
          ),

        // Nửa dưới: 2 avatar cạnh nhau
        if (displayMembers.length > 1)
          Expanded(
            flex: 1,
            child: Row(
              children: [
                // Avatar trái
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 1),
                    child: _buildSingleAvatar(displayMembers[1], 1),
                  ),
                ),

                // Avatar phải (nếu có)
                if (displayMembers.length > 2)
                  Expanded(
                    child: _buildSingleAvatar(displayMembers[2], 3),
                  ),

                // Nếu chỉ có 2 thành viên, hiển thị ô trống
                if (displayMembers.length == 2)
                  Expanded(
                    child: Container(
                      color: primary2.withOpacity(0.05),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSingleAvatar(AccountModel member, index) {
    if (member.avatar != null && member.avatar!.isNotEmpty) {
      return WidgetImageNetwork(
        width: index == 0 ? 50 : 20,
        url: member.avatar!,
        fit: BoxFit.cover,
        widgetError: _buildInitialAvatar(member),
      );
    } else {
      return _buildInitialAvatar(member);
    }
  }

  Widget _buildInitialAvatar(AccountModel member) {
    final String initial = _getInitial(member);

    return Container(
      decoration: BoxDecoration(
        color: primary2.withOpacity(0.2),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: primary2,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitial(AccountModel member) {
    if (member.accountFullname != null && member.accountFullname!.isNotEmpty) {
      return member.accountFullname![0].toUpperCase();
    } else if (member.accountUsername != null &&
        member.accountUsername!.isNotEmpty) {
      return member.accountUsername![0].toUpperCase();
    } else {
      return '?';
    }
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal();

    final isToday = now.year == localDateTime.year &&
        now.month == localDateTime.month &&
        now.day == localDateTime.day;

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = yesterday.year == localDateTime.year &&
        yesterday.month == localDateTime.month &&
        yesterday.day == localDateTime.day;

    if (isToday) {
      return DateFormat('HH:mm').format(localDateTime);
    } else if (isYesterday) {
      return 'Hôm qua';
    } else if (now.difference(localDateTime).inDays < 7) {
      // Hiển thị thứ, ví dụ: "Th 2", "Th 3", ...
      return DateFormat.E('vi_VN').format(localDateTime);
    } else {
      return DateFormat('dd/MM/yyyy').format(localDateTime);
    }
  }
}
