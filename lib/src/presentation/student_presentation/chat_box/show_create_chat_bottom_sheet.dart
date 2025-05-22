import 'package:flutter/material.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/model.dart';
import 'package:lms/src/utils/app_valid.dart';
import 'package:toastification/toastification.dart';

void showCreateChatBottomSheet(BuildContext context, ChatBoxViewModel viewModel) {
  final TextEditingController searchController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    scrollControlDisabledMaxHeightRatio: 0.9,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: formKey,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primary2,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Tạo nhóm trò chuyện mới',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          viewModel.selectedUsers.value = [];
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),

                // Content - Scrollable area
                Flexible(
                  child: CustomScrollView(
                    slivers: [
                      // Tên nhóm input
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: WidgetInput(
                            controller: viewModel.chatNameController,
                            titleText: 'Tên nhóm (tùy chọn)',
                            titleStyle: styleSmall.copyWith(color: grey2),
                            style: styleSmall.copyWith(color: grey2),
                            borderRadius: BorderRadius.circular(10),
                            validator: AppValid.validateRequireEnter(titleValid: 'Vui lòng nhập tên nhóm'),
                          ),
                        ),
                      ),

                      // Hiển thị các chip người dùng đã chọn
                      SliverToBoxAdapter(
                        child: ValueListenableBuilder<List<AccountModel>>(
                          valueListenable: viewModel.selectedUsers,
                          builder: (context, selected, child) {
                            if (selected.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Container(
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: selected
                                    .map((user) => Chip(
                                          backgroundColor: primary2.withOpacity(0.1),
                                          avatar: CircleAvatar(
                                            backgroundColor: primary2,
                                            child: Text(
                                              (user.accountFullname?.isNotEmpty == true
                                                  ? user.accountFullname![0].toUpperCase()
                                                  : 'U'),
                                              style: const TextStyle(color: white),
                                            ),
                                          ),
                                          label: Text(user.accountUsername ?? ''),
                                          deleteIcon: const Icon(Icons.close, size: 18),
                                          onDeleted: () => viewModel.removeUserFromSelection(user),
                                        ))
                                    .toList(),
                              ),
                            );
                          },
                        ),
                      ),

                      // Search input
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: WidgetInput(
                            controller: searchController,
                            hintText: 'Nhập tên hoặc email người dùng...',
                            prefix: const Icon(Icons.search, color: grey2),
                            borderRadius: BorderRadius.circular(12),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                viewModel.searchUsers(value);
                              }
                            },
                            widthPrefix: 40,
                            style: styleSmall.copyWith(color: grey2),
                          ),
                        ),
                      ),

                      // Search results
                      SliverToBoxAdapter(
                        child: ValueListenableBuilder<List<AccountModel>?>(
                          valueListenable: viewModel.searchResults,
                          builder: (context, searchResults, child) {
                            if (searchResults == null) {
                              return Container(
                                height: 100,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Nhập tên hoặc email để tìm kiếm người dùng',
                                  style: TextStyle(color: grey3),
                                ),
                              );
                            }

                            if (searchResults.isEmpty) {
                              return Container(
                                height: 100,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Không tìm thấy người dùng nào',
                                  style: TextStyle(color: grey3),
                                ),
                              );
                            }

                            return ValueListenableBuilder<List<AccountModel>>(
                              valueListenable: viewModel.selectedUsers,
                              builder: (context, selectedUsers, child) => ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: searchResults.length,
                                itemBuilder: (context, index) {
                                  final user = searchResults[index];
                                  final isSelected = selectedUsers.any((u) => u == user);
                                  return Card(
                                    color: white,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: WidgetImageNetwork(
                                        url: user.avatar,
                                        width: 40,
                                        height: 40,
                                        radiusAll: 100,
                                        widgetError: CircleAvatar(
                                          backgroundColor: primary2,
                                          child: Text(
                                            (user.accountFullname?.isNotEmpty == true
                                                ? user.accountFullname![0].toUpperCase()
                                                : 'U'),
                                            style: styleSmall.copyWith(color: white),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        user.accountFullname ?? '',
                                        style: styleSmallBold.copyWith(color: black),
                                      ),
                                      subtitle: Text(
                                        user.accountUsername ?? '',
                                        style: styleSmall.copyWith(color: grey2),
                                      ),
                                      trailing: isSelected
                                          ? const Icon(Icons.check, color: successLight)
                                          : ElevatedButton(
                                              onPressed: () {
                                                viewModel.addUserToSelection(user);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primary2,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text('Thêm'),
                                            ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      // Add spacing at the bottom
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 16),
                      ),
                    ],
                  ),
                ),

                // Footer - Nút tạo cuộc trò chuyện
                ValueListenableBuilder<List<AccountModel>>(
                  valueListenable: viewModel.selectedUsers,
                  builder: (context, selected, child) {
                    return Padding(
                      padding: const EdgeInsets.all(16).copyWith(bottom: 50),
                      child: SizedBox(
                        width: double.infinity,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: viewModel.isCreatingChat,
                          builder: (context, isCreating, _) {
                            return ElevatedButton(
                              onPressed: () {
                                if (selected.isEmpty || isCreating) {
                                  return;
                                }
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }
                                if (selected.length < 2) {
                                  viewModel.showToast(
                                      title: 'Số người trong nhóm không được bé hơn 2',
                                      type: ToastificationType.warning);
                                  return;
                                }
                                // Lấy danh sách email của người dùng đã chọn
                                final List<AccountModel> members = selected
                                    .map((user) => user)
                                    .where((user) => (user.accountUsername ?? '').isNotEmpty)
                                    .toList();

                                // Tạo chat box mới
                                viewModel.createNewChatBox(
                                  members: members,
                                );

                                // Đóng bottom sheet sau khi gửi yêu cầu
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selected.isEmpty ? Colors.grey : primary2,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isCreating
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(white),
                                      ),
                                    )
                                  : const Text(
                                      'Tạo cuộc trò chuyện',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
