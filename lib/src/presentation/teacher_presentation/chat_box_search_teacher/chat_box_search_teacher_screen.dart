import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms/src/configs/configs.dart';
import 'package:lms/src/presentation/presentation.dart';
import 'package:lms/src/resource/model/account_model.dart';
import 'package:lms/src/resource/model/chat_box_model.dart';

class ChatBoxSearchTeacherScreen extends StatefulWidget {
  const ChatBoxSearchTeacherScreen({Key? key}) : super(key: key);

  @override
  State<ChatBoxSearchTeacherScreen> createState() =>
      _ChatBoxSearchTeacherScreenState();
}

class _ChatBoxSearchTeacherScreenState extends State<ChatBoxSearchTeacherScreen>
    with SingleTickerProviderStateMixin {
  late ChatBoxSearchTeacherViewModel _viewModel;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  void _performSearch(String query) {
    if (_tabController.index == 0) {
      // Tìm kiếm người dùng
      _viewModel.searchAccounts(query);
    } else {
      // Tìm kiếm nhóm chat
      _viewModel.searchChatBox(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget<ChatBoxSearchTeacherViewModel>(
        viewModel: ChatBoxSearchTeacherViewModel(),
        onViewModelReady: (viewModel) {
          _viewModel = viewModel;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _viewModel.init();
          });
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: primary2,
              title: Text(
                'Tìm kiếm',
                style: TextStyle(color: white),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: white),
                onPressed: () => Get.back(),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(100),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: WidgetInput(
                        controller: _searchController,
                        autoFocus: true,
                        hintText: 'Tìm kiếm người dùng, đoạn chat...',
                        prefix: const Icon(Icons.search, color: grey2),
                        borderRadius: BorderRadius.circular(12),
                        widthPrefix: 40,
                        style: styleSmall.copyWith(color: grey3),
                        onChanged: (value) {
                          _performSearch(value);
                        },
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: white,
                      labelColor: white,
                      unselectedLabelColor: white.withOpacity(0.7),
                      tabs: [
                        Tab(text: 'Mọi người'),
                        Tab(text: 'Nhóm'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            body: SafeArea(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPeopleSearchResults(),
                  _buildGroupSearchResults(),
                ],
              ),
            ),
            backgroundColor: white,
          );
        });
  }

  Widget _buildPeopleSearchResults() {
    return ValueListenableBuilder<List<AccountModel>>(
      valueListenable: _viewModel.searchAccountResults,
      builder: (context, accounts, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: _viewModel.isSearching,
          builder: (context, isSearching, child) {
            if (isSearching) {
              return const Center(
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
                      'Nhập từ khóa để tìm kiếm người dùng',
                      style: styleMedium.copyWith(color: grey2),
                    ),
                  ],
                ),
              );
            }

            if (accounts.isEmpty) {
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
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final account = accounts[index];
                return _buildAccountItem(account);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGroupSearchResults() {
    return ValueListenableBuilder<List<ChatBoxModel>>(
      valueListenable: _viewModel.searchChatBoxResults,
      builder: (context, chatBoxes, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: _viewModel.isSearching,
          builder: (context, isSearching, child) {
            if (isSearching) {
              return const Center(
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
                      'Nhập từ khóa để tìm kiếm nhóm chat',
                      style: styleMedium.copyWith(color: grey2),
                    ),
                  ],
                ),
              );
            }

            if (chatBoxes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_off, size: 64, color: grey2),
                    SizedBox(height: 16),
                    Text(
                      'Không tìm thấy nhóm chat',
                      style: styleMedium.copyWith(color: grey2),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: chatBoxes.length,
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final chatBox = chatBoxes[index];
                return _buildChatBoxItem(chatBox);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAccountItem(AccountModel account) {
    final String displayName = account.accountFullname ??
        account.accountUsername ??
        'Người dùng không tên';
    final String initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Card(
      color: white,
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _viewModel.select<AccountModel>(account);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildAccountAvatar(account, initial),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: styleMediumBold.copyWith(color: grey),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatBoxItem(ChatBoxModel chatBox) {
    final String displayName = chatBox.name ?? 'Chat không tên';
    final bool isGroup = chatBox.group ?? false;
    final List<AccountModel> members = chatBox.memberAccountUsernames ?? [];

    return Card(
      color: white,
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _viewModel.select<ChatBoxModel>(chatBox);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildChatBoxAvatar(isGroup, members, displayName),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: styleMediumBold.copyWith(color: grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${members.length} thành viên',
                      style: styleSmall.copyWith(color: grey2),
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

  Widget _buildAccountAvatar(AccountModel account, String initial) {
    if (account.avatar != null && account.avatar!.isNotEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        clipBehavior: Clip.antiAlias,
        child: WidgetImageNetwork(
          url: account.avatar!,
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

  Widget _buildChatBoxAvatar(
      bool isGroup, List<AccountModel> members, String displayName) {
    int memberCount = members.length;

    if (isGroup) {
      return Stack(
        children: [
          Container(
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
              child: _buildSingleAvatar(displayMembers[0]),
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
                    child: _buildSingleAvatar(displayMembers[1]),
                  ),
                ),

                // Avatar phải (nếu có)
                if (displayMembers.length > 2)
                  Expanded(
                    child: _buildSingleAvatar(displayMembers[2]),
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

  Widget _buildSingleAvatar(AccountModel member) {
    if (member.avatar != null && member.avatar!.isNotEmpty) {
      return WidgetImageNetwork(
        url: member.avatar!,
        fit: BoxFit.cover,
        widgetError: _buildMemberInitialAvatar(member),
      );
    } else {
      return _buildMemberInitialAvatar(member);
    }
  }

  Widget _buildMemberInitialAvatar(AccountModel member) {
    final String initial = _getInitial(member);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
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
}
