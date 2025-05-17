import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/chat_box_model.dart';
import 'package:lms/src/resource/model/teacher_model.dart';
import 'package:lms/src/utils/app_prefs.dart';

class ChatBoxTeacherDetailScreen extends StatefulWidget {
  const ChatBoxTeacherDetailScreen({Key? key}) : super(key: key);

  @override
  State<ChatBoxTeacherDetailScreen> createState() =>
      _ChatBoxTeacherDetailScreenState();
}

class _ChatBoxTeacherDetailScreenState
    extends State<ChatBoxTeacherDetailScreen> {
  late ChatBoxTeacherDetailViewModel _viewModel;
  final Color grey0 = Colors.grey.shade200;
  final Color grey1 = Colors.grey.shade400;
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    currentUserEmail =
        AppPrefs.getUser<TeacherModel>(TeacherModel.fromJson)?.email;
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget<ChatBoxTeacherDetailViewModel>(
        viewModel: ChatBoxTeacherDetailViewModel(),
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
          return Row(
            children: [
              CircleAvatar(
                backgroundColor: white.withOpacity(0.2),
                radius: 20,
                child: Icon(
                  (chatbox?.group ?? false) ? Icons.group : Icons.person,
                  color: white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      chatbox?.name ?? 'Chat',
                      style: styleMediumBold.copyWith(color: white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (chatbox?.group ?? false)
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
          icon: const Icon(Icons.refresh, color: white),
          onPressed: _viewModel.refreshMessages,
          tooltip: 'Làm mới',
        ),
      ],
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
                    color: primary2.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.message_outlined,
                    size: 48,
                    color: primary2,
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

        // Group messages by date
        final Map<String, List<MessageModel>> groupedMessages = {};
        for (final message in messages) {
          if (message.createdAt != null) {
            final String date =
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

        return ListView.builder(
          controller: _viewModel.scrollController,
          reverse: false, // Tin nhắn cũ nhất ở trên, mới nhất ở dưới
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: dates.length + 1, // +1 cho loading indicator
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
                          valueColor: AlwaysStoppedAnimation<Color>(primary2),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
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
                    .map((message) => _buildMessageItem(message))
                    .toList(),
              ],
            );
          },
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

  Widget _buildMessageItem(MessageModel message) {
    final bool isMyMessage = message.senderAccount == currentUserEmail;
    final timeString = message.createdAt != null
        ? DateFormat('HH:mm').format(message.createdAt!.toLocal())
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMyMessage) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: primary2.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                size: 18,
                color: primary2,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment:
                isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMyMessage)
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Text(
                    message.senderAccount?.split('@').first ?? 'Unknown',
                    style: styleVerySmall.copyWith(
                        color: grey3, fontWeight: FontWeight.bold),
                  ),
                ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isMyMessage ? primary2 : grey0,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      message.content ?? '',
                      style: styleSmall.copyWith(
                        color: isMyMessage ? white : grey3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeString,
                      style: TextStyle(
                        color: isMyMessage ? white.withOpacity(0.7) : grey1,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isMyMessage) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: primary2),
            onPressed: () {
              // TODO: Implement file attachment
            },
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: grey0.withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _viewModel.messageController,
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: styleSmall.copyWith(color: grey1),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  isDense: true,
                ),
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _viewModel.sendMessage(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: primary2),
            onPressed: _viewModel.sendMessage,
          ),
        ],
      ),
    );
  }
}
