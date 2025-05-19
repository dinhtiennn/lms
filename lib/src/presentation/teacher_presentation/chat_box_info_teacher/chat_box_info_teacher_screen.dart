import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/chat_box_model.dart';

class ChatBoxInfoTeacherScreen extends StatefulWidget {
  const ChatBoxInfoTeacherScreen({Key? key}) : super(key: key);

  @override
  State<ChatBoxInfoTeacherScreen> createState() => _ChatBoxInfoTeacherScreenState();
}

class _ChatBoxInfoTeacherScreenState extends State<ChatBoxInfoTeacherScreen> {
  late ChatBoxInfoTeacherViewModel _viewModel;
  final Color grey0 = Colors.grey.shade200;
  final Color grey1 = Colors.grey.shade400;
  final Color grey2 = Colors.grey.shade600;
  final Color grey3 = Colors.grey.shade800;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<ChatBoxInfoTeacherViewModel>(
        viewModel: ChatBoxInfoTeacherViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _viewModel.init();
          });
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: SafeArea(child: _buildBody()),
            backgroundColor: white,
          );
        });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primary2,
      elevation: 0,
      centerTitle: true,
      title: ValueListenableBuilder(
        valueListenable: _viewModel.chatbox,
        builder: (context, chatbox, child) => Text(
          chatbox?.name ?? 'Cuộc hội thoại',
          style: styleMediumBold.copyWith(color: white),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: white),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder<ChatBoxModel?>(
      valueListenable: _viewModel.chatbox,
      builder: (context, chatbox, _) {
        if (chatbox == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primary2),
            ),
          );
        }

        final bool isGroup = chatbox.group ?? false;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildChatBoxInfoHeader(chatbox),
              const SizedBox(height: 24),
              _buildChatBoxDetails(chatbox),
              if (isGroup) _buildMembersList(chatbox),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatBoxInfoHeader(ChatBoxModel chatbox) {
    final bool isGroup = chatbox.group ?? false;

    return Column(
      children: [
        Text(
          isGroup ? '${chatbox.memberAccountUsernames?.length ?? 0} thành viên' : 'Cuộc trò chuyện riêng',
          style: styleSmall.copyWith(color: grey2),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildChatBoxDetails(ChatBoxModel chatbox) {
    final DateTime? createdAt = chatbox.createdAt;
    final String createdBy = chatbox.createdBy ?? 'Không xác định';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin chi tiết',
            style: styleMediumBold.copyWith(color: grey3),
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            icon: Icons.calendar_today,
            title: 'Ngày tạo',
            value: createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt) : 'Không xác định',
          ),
          const Divider(height: 24),
          _buildDetailItem(
            icon: Icons.person_outline,
            title: 'Người tạo',
            value: createdBy,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primary2, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: styleSmallBold.copyWith(color: grey3),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: styleSmall.copyWith(color: grey2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMembersList(ChatBoxModel chatbox) {
    final List<String> members = chatbox.memberAccountUsernames ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thành viên',
                style: styleMediumBold.copyWith(color: grey3),
              ),
              Text(
                '${members.length} người',
                style: styleSmall.copyWith(color: grey2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (members.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Không có thành viên nào',
                  style: styleSmall.copyWith(color: grey1),
                ),
              ),
            )
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: members.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) => _buildMemberItem(members[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(String memberEmail) {
    final String displayName = memberEmail.split('@')[0];
    final String avatarText = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: primary2.withOpacity(0.7),
        radius: 20,
        child: Text(
          avatarText,
          style: const TextStyle(color: white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        displayName,
        style: styleSmall.copyWith(color: grey3),
      ),
      subtitle: Text(
        memberEmail,
        style: styleVerySmall.copyWith(color: grey2),
      ),
    );
  }
}
