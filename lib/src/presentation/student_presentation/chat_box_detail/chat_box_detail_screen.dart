import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/chat_box_model.dart';
import 'package:lms/src/resource/model/account_model.dart';

class ChatBoxDetailScreen extends StatefulWidget {
  const ChatBoxDetailScreen({Key? key}) : super(key: key);

  @override
  State<ChatBoxDetailScreen> createState() =>
      _ChatBoxDetailScreenState();
}

class _ChatBoxDetailScreenState
    extends State<ChatBoxDetailScreen> {
  late ChatBoxDetailViewModel _viewModel;
  final Color grey0 = Colors.grey.shade200;
  final Color grey1 = Colors.grey.shade400;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<ChatBoxDetailViewModel>(
        viewModel: ChatBoxDetailViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _viewModel.init();
          });
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: _buildChatMessages(),
                  ),
                  _buildInputArea(),
                ],
              ),
            ),
            backgroundColor: white,
          );
        });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primary2,
      elevation: 0,
      title: ValueListenableBuilder<ChatBoxModel?>(
        valueListenable: _viewModel.chatbox,
        builder: (context, chatbox, _) {
          // Lấy thông tin người dùng hiện tại
          final String currentUserEmail = _viewModel.currentUserEmail ?? '';

          // Xác định tên hiển thị và thông tin người đối diện
          String displayName = '';
          AccountModel? otherUser;
          bool isGroup = chatbox?.group ?? false;

          if (isGroup) {
            // Nếu là nhóm chat, hiển thị tên nhóm
            displayName = chatbox?.name ?? 'Nhóm không tên';
          } else {
            // Nếu là chat 1-1, tìm người đối diện
            if (chatbox?.memberAccountUsernames != null &&
                chatbox!.memberAccountUsernames!.isNotEmpty) {
              // Tìm tài khoản không phải là người dùng hiện tại
              otherUser = chatbox.memberAccountUsernames!.firstWhere(
                  (member) => member.accountUsername != currentUserEmail,
                  orElse: () => chatbox.memberAccountUsernames!.first);

              // Lấy tên hiển thị từ tài khoản đối diện
              displayName = otherUser.accountFullname ??
                  otherUser.accountUsername ??
                  'Người dùng không tên';
            } else {
              displayName = 'Chat không tên';
            }
          }

          return Row(
            children: [
              isGroup
                  ? _buildGroupAvatar(chatbox?.memberAccountUsernames ?? [])
                  : _buildUserAvatar(otherUser, displayName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: styleMediumBold.copyWith(color: white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isGroup)
                      Text(
                        '${chatbox?.memberAccountUsernames?.length ?? 0} thành viên',
                        style: styleVerySmall.copyWith(
                            color: white.withOpacity(0.7)),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: white),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: white),
          onPressed: () {
            _viewModel.settingBoxChat();
          },
          tooltip: 'Thông tin',
        ),
      ],
    );
  }

  Widget _buildGroupAvatar(List<AccountModel> members) {
    return CircleAvatar(
      backgroundColor: white.withOpacity(0.2),
      radius: 20,
      child: members.isNotEmpty
          ? _buildGroupAvatarContent(members)
          : Icon(Icons.group, color: white),
    );
  }

  Widget _buildGroupAvatarContent(List<AccountModel> members) {
    final displayMembers = members.take(3).toList();

    return ClipOval(
      child: Container(
        color: white.withOpacity(0.1),
        child: Column(
          children: [
            // Nửa trên: 1 avatar
            if (displayMembers.isNotEmpty)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: _buildSingleMemberAvatar(displayMembers[0], index: 0),
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
                        child: _buildSingleMemberAvatar(displayMembers[1]),
                      ),
                    ),

                    // Avatar phải (nếu có)
                    if (displayMembers.length > 2)
                      Expanded(
                        child: _buildSingleMemberAvatar(displayMembers[2]),
                      ),

                    // Nếu chỉ có 2 thành viên, hiển thị ô trống
                    if (displayMembers.length == 2)
                      Expanded(
                        child: Container(
                          color: primary2.withOpacity(0.1),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleMemberAvatar(AccountModel member,{ int? index = 5}) {
    if (member.avatar != null && member.avatar!.isNotEmpty) {
      return WidgetImageNetwork(
        width: index == 0 ? 50: 20,
        url: member.avatar!,
        fit: BoxFit.cover,
        widgetError: _buildMemberInitialAvatar(member),
      );
    } else {
      return _buildMemberInitialAvatar(member);
    }
  }

  Widget _buildMemberInitialAvatar(AccountModel member) {
    final String initial = _getMemberInitial(member);

    return Container(
      color: primary2.withOpacity(0.2),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getMemberInitial(AccountModel member) {
    if (member.accountFullname != null && member.accountFullname!.isNotEmpty) {
      return member.accountFullname![0].toUpperCase();
    } else if (member.accountUsername != null &&
        member.accountUsername!.isNotEmpty) {
      return member.accountUsername![0].toUpperCase();
    } else {
      return '?';
    }
  }

  Widget _buildUserAvatar(AccountModel? user, String displayName) {
    if (user != null && user.avatar != null && user.avatar!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: white.withOpacity(0.2),
        child: ClipOval(
          child: WidgetImageNetwork(
            url: user.avatar!,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            widgetError: _buildDefaultUserAvatar(displayName),
          ),
        ),
      );
    } else {
      return _buildDefaultUserAvatar(displayName);
    }
  }

  Widget _buildDefaultUserAvatar(String displayName) {
    return CircleAvatar(
      backgroundColor: white.withOpacity(0.2),
      radius: 20,
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
        style: TextStyle(
          color: white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChatMessages() {
    return ValueListenableBuilder<List<MessageModel>?>(
      valueListenable: _viewModel.messages,
      builder: (context, messages, _) {
        if (messages == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primary2),
            ),
          );
        }

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primary3.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.message_outlined,
                    size: 48,
                    color: primary3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Không có tin nhắn nào',
                  style: styleMedium.copyWith(color: grey3),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hãy bắt đầu cuộc trò chuyện!',
                  style: styleSmall.copyWith(color: grey1),
                ),
              ],
            ),
          );
        }

        final Map<String, List<MessageModel>> groupedMessages = {};
        for (final message in messages) {
          if (message.createdAt != null) {
            String date =
                DateFormat('dd/MM/yyyy').format(message.createdAt!.toLocal());
            if (!groupedMessages.containsKey(date)) {
              groupedMessages[date] = [];
            }
            groupedMessages[date]!.add(message);
          }
        }

        // Sắp xếp ngày tăng dần (cũ nhất lên trên)
        final List<String> dates = groupedMessages.keys.toList()
          ..sort((a, b) {
            final DateFormat format = DateFormat('dd/MM/yyyy');
            final DateTime dateA = format.parse(a);
            final DateTime dateB = format.parse(b);
            return dateA.compareTo(dateB);
          });

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            // Kiểm tra khi người dùng cuộn đến đầu danh sách
            if (scrollInfo.metrics.pixels <=
                    scrollInfo.metrics.minScrollExtent + 50 &&
                !_viewModel.isLoading &&
                _viewModel.hasMoreMessages) {
              // Gọi loadMoreMessages khi cuộn gần đến đầu danh sách
              _viewModel.loadMoreMessages();
            }
            return false;
          },
          child: ListView.builder(
            controller: _viewModel.scrollController,
            reverse: false,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: dates.length + 1,
            // +1 cho loading indicator
            itemBuilder: (context, index) {
              // Hiển thị loading indicator ở đầu danh sách
              if (index == 0) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _viewModel.isLoadingMore,
                  builder: (context, isLoading, _) {
                    if (isLoading) {
                      return Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(primary3),
                          ),
                        ),
                      );
                    }
                    return const SizedBox(height: 20);
                  },
                );
              }

              final dateIndex = index - 1;
              final date = dates[dateIndex];
              final messagesForDate = groupedMessages[date]!;

              // Sắp xếp tin nhắn trong ngày theo thời gian tăng dần
              messagesForDate.sort((a, b) {
                return (a.createdAt ?? DateTime.now())
                    .compareTo(b.createdAt ?? DateTime.now());
              });

              return Column(
                children: [
                  _buildDateDivider(date),
                  ...messagesForDate
                      .map((message) => _buildMessageItem(context, message))
                      .toList(),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDateDivider(String date) {
    final now = DateTime.now();
    final today = DateFormat('dd/MM/yyyy').format(now);
    final yesterday =
        DateFormat('dd/MM/yyyy').format(now.subtract(const Duration(days: 1)));

    String displayDate;
    if (date == today) {
      displayDate = 'Hôm nay';
    } else if (date == yesterday) {
      displayDate = 'Hôm qua';
    } else {
      displayDate = date;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: grey0, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              displayDate,
              style: styleVerySmall.copyWith(color: grey1),
            ),
          ),
          Expanded(child: Divider(color: grey0, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, MessageModel message) {
    final bool isCurrentUser =
        message.senderAccount?.accountUsername == _viewModel.currentUserEmail;

    final String senderDisplayName =
        message.senderAccount?.accountFullname?.split('@')[0] ?? 'Unknown';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser)
            WidgetImageNetwork(
              url: message.senderAccount?.avatar,
              radiusAll: 100,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              widgetError: CircleAvatar(
                backgroundColor: primary3,
                radius: 16,
                child: Text(
                  (message.senderAccount?.accountFullname ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(color: white, fontSize: 12),
                ),
              ),
            ),
          if (!isCurrentUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isCurrentUser ? primary2.withOpacity(0.8) : white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        senderDisplayName,
                        style: styleVerySmall.copyWith(
                          color: primary2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    message.content ?? '',
                    style: styleSmall.copyWith(
                      color: isCurrentUser ? white : black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: isCurrentUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Text(
                        _formatMessageTime(message.createdAt),
                        style: styleVerySmall.copyWith(
                          color: isCurrentUser
                              ? white.withOpacity(0.7)
                              : grey3.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                      if (isCurrentUser)
                        Icon(
                          Icons.check,
                          size: 12,
                          color: white.withOpacity(0.7),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (dateToCheck == today) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (dateToCheck == yesterday) {
      return 'Hôm qua ${DateFormat('HH:mm').format(timestamp)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
    }
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 5,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: WidgetInput(
                controller: _viewModel.messageController,
                hintText: 'Nhập tin nhắn...',
                maxLines: 5,
                hintStyle: styleSmall.copyWith(color: grey4),
                style: styleSmall.copyWith(color: grey),
                borderRadius: BorderRadius.circular(24),
                textInputAction: TextInputAction.send,
                onSubmit: (_) => _viewModel.sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            // Nút gửi tin nhắn
            ValueListenableBuilder<bool>(
              valueListenable: _viewModel.isSendingMessage,
              builder: (context, isSending, _) {
                return RawMaterialButton(
                  onPressed: isSending ? null : _viewModel.sendMessage,
                  shape: const CircleBorder(),
                  constraints:
                      const BoxConstraints(minWidth: 48, minHeight: 48),
                  elevation: 0,
                  child: isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(primary3),
                          ),
                        )
                      : const Icon(Icons.send, color: primary3),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
