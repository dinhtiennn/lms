import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/account_model.dart';
import 'package:lms/src/resource/model/chat_box_model.dart';

class ChatBoxMemberScreen extends StatefulWidget {
  const ChatBoxMemberScreen({Key? key}) : super(key: key);

  @override
  State<ChatBoxMemberScreen> createState() => _ChatBoxMemberScreenState();
}

class _ChatBoxMemberScreenState extends State<ChatBoxMemberScreen> {
  late ChatBoxMemberViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget<ChatBoxMemberViewModel>(
        viewModel: ChatBoxMemberViewModel(),
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
                'Thành viên nhóm',
                style: TextStyle(color: white),
              ),
              backgroundColor: primary2,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: white),
                onPressed: () => Get.back(result: _viewModel.chatBox.value),
              ),
              actions: [
                ValueListenableBuilder(valueListenable: _viewModel.chatBox, builder: (context, chatBox, child) {
                  final bool isCreator = chatBox?.createdBy == _viewModel.currentUserEmail;
                  return isCreator
                      ? IconButton(
                    icon: Icon(Icons.person_add, color: white),
                    onPressed: () => _showAddMemberBottomSheet(context),
                    tooltip: 'Thêm thành viên',
                  )
                      : SizedBox.shrink();
                },)
              ],
            ),
            body: SafeArea(child: _buildBody()),
            backgroundColor: white,
          );
        });
  }

  Widget _buildBody() {
    return ValueListenableBuilder<ChatBoxModel?>(
      valueListenable: _viewModel.chatBox,
      builder: (context, chatBox, _) {
        if (chatBox == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primary2),
            ),
          );
        }

        final List<AccountModel> members = chatBox.memberAccountUsernames ?? [];

        if (members.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: grey2),
                SizedBox(height: 16),
                Text(
                  'Không có thành viên nào',
                  style: styleMedium.copyWith(color: grey2),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: members.length,
          padding: EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final member = members[index];
            return _buildMemberItem(member);
          },
        );
      },
    );
  }

  Widget _buildMemberItem(AccountModel member) {
    final String displayName = member.accountFullname ?? member.accountUsername ?? 'Người dùng không tên';
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    // Kiểm tra xem người dùng hiện tại có phải là người tạo chatbox không
    final bool isCreator = _viewModel.chatBox.value?.createdBy == _viewModel.currentUserEmail;

    // Kiểm tra xem thành viên có phải là người dùng hiện tại không
    final bool isSelf = member.accountUsername == _viewModel.currentUserEmail;

    return Card(
      color: white,
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildMemberAvatar(member, initial),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: styleMediumBold.copyWith(color: grey2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (member.accountUsername != null)
                    Text(
                      member.accountUsername!,
                      style: styleSmall.copyWith(color: grey2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Hiển thị nút xóa thành viên nếu người dùng hiện tại là người tạo chatbox và thành viên không phải là bản thân
            if (isCreator && !isSelf)
              IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _showRemoveMemberDialog(member),
                tooltip: 'Xóa khỏi nhóm',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberAvatar(AccountModel member, String initial) {
    if (member.avatar != null && member.avatar!.isNotEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: WidgetImageNetwork(
          url: member.avatar!,
          fit: BoxFit.cover,
          widgetError: _buildInitialAvatar(initial),
        ),
      );
    } else {
      return _buildInitialAvatar(initial);
    }
  }

  Widget _buildInitialAvatar(String initial) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: primary2.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: primary2,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddMemberBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) {
        _searchController.clear();
        _viewModel.resetSearch();
        return _buildAddMemberBottomSheet(context);
      },
    );
  }

  Widget _buildAddMemberBottomSheet(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thêm thành viên',
                  style: styleMediumBold.copyWith(color: grey3),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: grey3),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),

          // Search Input
          Padding(
            padding: EdgeInsets.all(16),
            child: WidgetInput(
              controller: _searchController,
              hintText: 'Tìm kiếm người dùng...',
              prefix: Icon(Icons.search, color: grey2),
              borderRadius: BorderRadius.circular(12),
              widthPrefix: 40,
              autoFocus: true,
              style: styleSmall.copyWith(color: grey3),
              onChanged: (value) {
                _viewModel.searchAccounts(value);
              },
            ),
          ),

          // Search Results
          Expanded(
            child: ValueListenableBuilder<List<AccountModel>?>(
              valueListenable: _viewModel.searchAccountResults,
              builder: (context, accounts, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _viewModel.isSearching,
                  builder: (context, isSearching, _) {
                    if (isSearching) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(primary2),
                        ),
                      );
                    }

                    if (_searchController.text.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 64, color: grey2),
                            SizedBox(height: 16),
                            Text(
                              'Nhập tên để tìm kiếm người dùng',
                              style: styleMedium.copyWith(color: grey2),
                            ),
                          ],
                        ),
                      );
                    }

                    if (accounts == null || accounts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off, size: 64, color: grey2),
                            SizedBox(height: 16),
                            Text(
                              'Không tìm thấy người dùng',
                              style: styleMedium.copyWith(color: grey2),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: accounts.length,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final account = accounts[index];
                        return _buildAccountSearchItem(account, context);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSearchItem(AccountModel account, BuildContext context) {
    final String displayName = account.accountFullname ?? account.accountUsername ?? 'Người dùng không tên';
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Card(
      color: white,
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildMemberAvatar(account, initial),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: styleMedium.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (account.accountUsername != null)
                    Text(
                      account.accountUsername!,
                      style: styleSmall.copyWith(color: grey2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: primary2),
              onPressed: () {
                _viewModel.addUserToChat(account);
              },
              tooltip: 'Thêm vào nhóm',
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị hộp thoại xác nhận trước khi xóa thành viên
  void _showRemoveMemberDialog(AccountModel member) {
    final String displayName = member.accountFullname ?? member.accountUsername ?? 'Người dùng không tên';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: white,
        title: Text(
          'Xóa thành viên',
          style: styleMediumBold.copyWith(color: error),
        ),
        content: Text('Bạn có chắc chắn muốn xóa $displayName khỏi nhóm chat không?',
            style: styleSmall.copyWith(color: grey3)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: grey3)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              _viewModel.removeMember(member); // Xóa thành viên
            },
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
